
## AYDbModel

### 数据库表的创建与升级
　　AYDbModel的`Configuration`分类中默认实现一些静态类方法。用户可以选择重写一部分方法用于自定义表名、自定义字段属性、插入初始化数据等。

```objective-c
/**
 *  Config table.
 */
@interface AYDbModel<M>(Configuration)
+ (NSString *)tableName;/**< Return table name of the model. default is class name. */
+ (NSInteger)version;/**< Return current version of the model. default is 1.*/
+ (NSString *)propertyForColumn:(NSString *)column;/**< Return property of column. */
+ (NSArray<AYDbSql *> *)migrateForm:(NSInteger)oldVersion to:(NSInteger)newVersion;/**< Return sqls for migration. default is nil.*/
@end
```
　　重写`tableName`方法，可以自定义数据库表的名称。
>若表已经建立了，再更改此方法是无效的，并且可能会引起一些错误。因此一旦定义了表名之后，不要再改动此方法了。

　　重写`version`方法，返回当前表的版本。默认为1。当用户重写并返回大于当前的版本号，AYRecord会重新检查表的结构与实体是否相符。如果发现新字段，将会自动添加新属性到数据库表中。
>由于sqlite不支持删除表的字段，所以被删除的列仅仅只是在查询时屏蔽了该字段。

　　重写`propertyForColumn:`，用于自定义列的属性，如下：

```objective-c
//age的默认值为10，name不能为空
+ (NSString *)propertyForColumn:(NSString *)column{
    if ([column isEqualToString:@"age"]) {
        return @"default 10";
    }else if ([column isEqualToString:@"name"){
        return @"not null";
    }
    return nil;
}
```
>`propertyForColumn:`返回的字符串会直接拼接在字段后，如**ALTER TABLE Student ADD subject TEXT <mark>default '语文'</mark>**

　　AYRecord在建表和升级表之后，会调用`updatesForm:to:`方法，用户可以重写此方法，返回sqls用于添加初始化数据或增加外键、唯一键之类。

```objective-c
//返回从旧版本升级到新版本所需要的sqls
//oldVersion为0的时候，代表初始化数据库
+ (NSArray<NSString *> *)updatesForm:(NSInteger)oldVersion to:(NSInteger)newVersion{
        NSMutableArray *updateSqls = [NSMutableArray new];
    switch (oldVersion) {
        case 0://初始化数据
            [updateSqls addObject:[AYDbSql buildSql:@"insert into student(name, age) values(?, ?)", @"张三", @24]];
            [updateSqls addObject:[AYDbSql buildSql:@"insert into student(name, age) values(?, ?)", @"李四", @25]];
        case 1:
        default:
            break;
    }
    return updateSqls;
}
//返回当前表版本，默认version为1
+ (NSInteger)version{
    return 2;
}
```
>建表时，AYRecord会调用`[Student updatesForm:0 to:1]`

>建表时，`[+version]`若是返回3，则会调用`[Student updatesForm:0 to:3]`

>升级表时，若原来的版本是2，`[+version]`返回5的话，会调用`[Student updatesForm:2 to:5]`

### 增删改查
　　以上代码中的Teacher类通过继承AYDbModel，便立即拥有众多方便的操作数据库的方法。

```objective-c
   //创建name属性为Jack，age属性为40的Teacher对象并添加到数据库
   Teacher *newTeacher = [Teacher new];
   newTeacher.name = @"Jack";
   newTeacher.age = 40;
   [newTeacher save];
   
/************************************************************/
   //删除id值为11的Teacher
   [[Teacher dao] deleteById:11];

/************************************************************/
   //查询id值为11的Teacher，将其name属性改为Jack并更新到数据库
   Teacher *aTeacher = [[Teacher dao] findById:11];
   aTeacher.name = @"Jack";
   [aTeacher update];

/************************************************************/
   //查询所有年龄大于30岁的Teacher
   NSArray<Teacher *> *teachers = [[Teacher dao] find:@"select * from teacher where age > ?", @30];
   NSArray<Teacher *> *teachers = [[Teacher dao] findByCondition:@"age > ?", @30];
   
   //分页查询年龄大于30岁的Teacher，当前页号为1，每页10个Teacher记录
   PSPage<Teacher *> *teacherPage = [[Teacher dao] paginate(1, 10, @"select *", @"from teacher where age > ?", @30);
```
> AYDbModel 还提供了很多其它的方便的方法

## AYDbTypeConvertor
　　AYRecord具有一个非常方便的特性，我把它叫做属性修正。什么是属性修正，举个例子：

```objective-c
    //查询出生日期在2002年5月9日之后的学生
    NSDate *date = [@"2002-05-09" ps_dateValue:@"yyyy-MM-dd"];
    NSArray<Student *> *results = [[Student dao] findByCondition:@"born > ?", date];
```
　　在上面的查询中，`findByCondition:`方法中的条件参数，传入的是一个NSDate对象，AYRecord在执行SQL的时候，会将它转换成适当的数据用于查询。这是因为AYRecord为NSDate类实现了一个名为`AYNSDateConvertor`的属性转换器，因此，NSDate可以作为Model的属性，查询条件等。

　　Convertor需要实现AYDbTypeConvertor协议，以下是该协议的方法列表

```objective-c
#define AYDbSqliteTypeNULL @"NULL"
#define AYDbSqliteTypeINTEGER @"INTEGER"
#define AYDbSqliteTypeREAL @"REAL"
#define AYDbSqliteTypeTEXT @"TEXT"
#define AYDbSqliteTypeBLOG @"BLOG"

typedef struct sqlite3_stmt sqlite3_stmt;

/**
 *  Property vlaue convertor
 *  convert property type to objc type
 */
@protocol AYDbTypeConvertor<NSObject>
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) Class objcType;
@property (nonatomic, readonly) NSString *dataType;
@property (nonatomic, readonly) NSMethodSignature *setterSignature;
@property (nonatomic, readonly) NSMethodSignature *getterSignature;

- (void)bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt *)statement;

- (id)getBuffer:(void *)buffer fromObject:(id)obj;
- (id)objectForBuffer:(void *)buffer;
@end

```
　　以下是AYNSDateConvertor的实现，用于解释AYDbTypeConvertor是如何工作的。注释是用于解释方法的用处：

```objective-c
//AYNSDateConvertor.h
@interface AYNSDateConvertor : NSObject<AYDbTypeConvertor>
@end

//AYNSDateConvertor.m
#import "AYNSDateConvertor.h"
#import "AYRecord_private.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface AYNSDateConvertor()
//模拟NSDate作为成员属性
@property(nonatomic, retain) NSDate *signature;
@end

@implementation AYNSDateConvertor
//获取属性的类型（可以直接复制以下代码）
- (NSString *)type{
    static NSString *_type = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_property_t property = class_getProperty(self.class, "signature");
        char *type = property_copyAttributeValue(property, "T");
        _type = @(type);
        free((void *)type);
    });
    return _type;
}
//返回NSDate类型以什么形式存储。
//由于NSDate是OC对象，所以可以直接存储在数组或字典中，所以直接返回NSDate的类型即可。
//如果是基本类型，一般是返回保存它的OC对象，比如double类型返回NSNumber，CGRect返回NSValue
- (Class)objcType{
    return NSDate.class;
}
//NSDate在数据库中使用REAL作为字段的属性
//如果返回的是AYDbSqliteTypeBLOG的话，则只能使用=，而不能再使用>、<来对比字段的值了。
- (NSString *)dataType{
    return AYDbSqliteTypeREAL;
}
//Setter方法签名（可以直接复制以下代码）
- (NSMethodSignature *)setterSignature{
    return [self methodSignatureForSelector:@selector(setSignature:)];
}
//Getter方法签名（可以直接复制以下代码）
- (NSMethodSignature *)getterSignature{
    return [self methodSignatureForSelector:@selector(signature)];
}
//NSDate对象绑定到sql时，是如何处理的
//由于在此Convertor中，NSDate是使用REAL类型存储的，所以这里将NSDate对象转换成double类型，并绑定到statement中
- (void)bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt *)statement{
    sqlite3_bind_double(statement, idx, [obj timeIntervalSince1970]);
}

//当用户调用了 NSDate *born = aStu.born时，此方法将会被调用。
//此方法用于将obj转换成NSDate对象，并将对象放入缓冲buffer，之后AYRecord会将缓冲里的对象返回给用户。
//由于数据库中，NSDate是以REAL类型保存的，所以读出来的时候，是NSNumber(double)类型，因此不能直接将它返回给用户，所以要将NSNumber转换成NSDate对象。
//转换之后，将NSDate对象返回，在下一次用户取aStu.born的值时，obj的类型就是NSDate类型了，可以不需要转换直接放入缓冲中，以优化性能。
- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    if ([obj isKindOfClass:[NSNumber class]]) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[obj doubleValue]];
        memcpy(buffer, (void *)&date, sizeof(id));
        return date;
    }else if ([obj isKindOfClass:[NSDate class]]){
        memcpy(buffer, (void *)&obj, sizeof(id));
        return nil;
    }
    PSAssertFail(@"can not conver <%@ %p>:%@ to NSDate", [obj class], obj, obj);
    return nil;
}
//当用户调用了aStu.born = date时，此方法将会被调用
//用于将缓冲的内存对象转换成OC类型的对象。
//由于NSDate本身是OC类型的对象，所以可以直接将对象从缓冲中拿出来，返回
//如果是基本类型，如double，则需要先将double从缓冲中拿出来，包装成NSNumber对象之后再返回。
- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    __unsafe_unretained id obj = nil;
    memcpy(&obj, buffer, sizeof(id));
    return obj;
}
@end
```
　　目前，AYRecord默认实现了以下Convertor

Objective-C Type   | Property Attribute               | Store Type               | Data Type |
-------------------|----------------------------------|--------------------------|-----------|
char               | c                                | NSNumber                 | INTEGER   |
unsigned char      | C                                | NSNumber                 | INTEGER   |
short              | s                                | NSNumber                 | INTEGER   |
unsigned short     | S                                | NSNumber                 | INTEGER   |
int                | i                                | NSNumber                 | INTEGER   |
unsigned int       | I                                | NSNumber                 | INTEGER   |
long               | l (q 64bit)                      | NSNumber                 | INTEGER   |
unsigned long      | L (Q 64bit)                      | NSNumber                 | INTEGER   |
long long          | q                                | NSNumber                 | INTEGER   |
unsigned long long | Q                                | NSNumber                 | INTEGER   |
float              | f                                | NSNumber                 | REAL      |
double             | d                                | NSNumber                 | REAL      |
bool               | c                                | NSNumber                 | INTEGER   |
Class              | #                                | Class/NSString           | TEXT      |
NSData             | @"NSData"                        | NSData                   | BLOG      |
NSDate             | @"NSDate"                        | NSDate/NSNumber          | REAL      |
NSDecimalNumber    | @"NSDecimalNumber"               | NSDecimalNumber/NSString | TEXT      |
NSString           | @"NSString"                      | NSString                 | TEXT      |
NSURL              | @"NSURL"                         | NSURL/NSString           | TEXT      |
UIColor            | @"UIColor"                       | UIColor/NSNumber         | INTEGER   |
NSValue            | @"NSValue"                       | NSValue/NSData           | BLOG      |
CGAffineTransform  | {CGAffineTransform=dddddd}       | NSValue/NSData           | BLOG      |
CGPoint            | {CGPoint=dd}                     | NSValue/NSData           | BLOG      |
CGRect             | {CGRect={CGPoint=ff}{CGSize=ff}} | NSValue/NSData           | BLOG      |
CGSize             | {CGSize=dd}                      | NSValue/NSData           | BLOG      |
CGVector           | {CGVector=dd}                    | NSValue/NSData           | BLOG      |
UIEdgeInsets       | {UIEdgeInsets=dddd}              | NSValue/NSData           | BLOG      |
UIOffset           | {UIOffset=dd}                    | NSValue/NSData           | BLOG      |
NSRange            | {_NSRange=QQ}                    | NSValue/NSData           | BLOG      |
　　实现了Convertor的Objective-C Type可以在模型中直接使用。

```objective-c
@interface Student : AYDbModel<Student *>
@property (nonatomic) UIColor color;//支持，因为已经为UIColor实现了Convertor
@property (nonatomic) CGColorRef colorRef;//不支持，因为没有为CGColorRef实现Convertor
@end
```

>Store Type中，有的类型会出现两种存储类型(Store Type)。这是因为从数据库取出来的时候，并没有将它即时转换成合适的类型，而是在用到时，再将它通过对应的Convertor转换成合适的类型返回。所以数据从数据库转换成Model的时候，速度可以非常快。

>由以上面的原因，当用户使用KVC来取数据的时候，很有可能取出来的对象类型不是期望的类型。如NSDate *date = [aStu valueForKey:@"born"]，此时的date对象<mark>既可能是NSNumber类型，也可能是NSDate类型</mark>。同样，使用KVC设置属性的时候，也可以使用NSNumber类型或NSDate类型，在保存到数据库时，Convertors会处理好它们之间的转换的。
>`[aStu setValue:@(1020873600) forKey:@"born"]`和`[aStu setValue:date forKey:@"born"]`都是正确的。

## AYDb + AYDbEntry模式
　　AYDb类及其配套的AYDbEntry类，提供用户使用SQL来操作数据库。同时，AYDb提供事务处理、批量执行SQL等功能。

```objective-c
    NSMutableArray<AYDbSql *> *sqls = [NSMutableArray array];
    for (int i = 0; i < 3000; i ++) {
        [sqls addObject:[AYDbSql buildSql:@"insert into student(name, age) values(?, ?)", [NSString stringWithFormat:@"张%d", i], @(i)]];
    }
    //批量执行3000条insert语句
    [[AYDb main] batchSqls:sqls];
    
    //事务
    [[AYDb main] tx:^BOOL(AYDb *db){
        BOOL success = [db update:@"update account set cash = cash - ? where id = ?", 100, 123];
        success &= [db update:@"update account set cash = cash + ?  where id = ?", 100, 456];
        return success;
    }];
```
> 以上两个数据库更新操作在一个事务中执行，如果执行过程中`发生异常`或者block`返回值为NO`，则自动回滚事务。

## 表关联操作
　　AYRecord天然支持表关联操作，并不需要学习新的东西。表关联操作主要有两种方式：一是直接使用sql得到关联数据，然后使用KVC获取表外的数据；二是在Model中添加获取关联数据的方法。

　　假定有两张数据库表：teacher、student，并且teacher到student是一对多关系，student表中使用teacher\_id关联到teacher表。
### 直接使用SQL查询
```objective-c
   Student *student = [[Student dao] findFirst:@"select s.*, t.name t_name from student s, teacher t where s.teacher_id = t.id"];
   NSString *teacherName = [student valueForKey:@"t_name"];
```
### 关联属性

```objective-c
@interface Student : PSMolde<Student *>
...//Student其它代码
@property (nonatomic, readonly) Teacher *teacher;
@end

@implementation Student
...//Student其它代码
- (Teacher *)teacher{
    return [[Teacher dao] findById:self.teacher_id];
}
@end

/***************************************************************/
@interface Teacher : AYDbModel<Teacher *>
...//Teacher其它代码
@property (nonatomic, readonly) NSArray<Student *> *students;
@end

@implementation Teacher
...//Teacher其它代码
- (NSArray<Student *> *)students{
    return [[Student dao] findByCondition:@"teacher_id = ?", self.ID]];
}
@end
```
## 多数据源支持
---
　　AYRecord可同时支持多数据源上下文，对每个上下文可以进行彼此独立的配置。

　　当使用多数据源时，只需要对每个AYDbContext指定一个`configName`即可，如下代码示例：

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    AYDbContext *drStu = [[AYDbContext alloc] initWithDataSource:@"Document/db/Student.db"];
    [drStu registerModel:[Student class]];
    [drStu start];
    
    AYDbContext *drTea = [[AYDbContext alloc] initWithDataSource:@"Document/db/Teacher.db" forConfig:@"TeacherDatasource"];
    [drTea registerModel:[Teacher class]];
    [drTea start];
    
    return YES;
}
```
　　以上代码创建了两个AYDbContext实例drStu与drTea，<mark>特别注意</mark>，创建drTea时，指定了其configName为"TeacherDatasource"，而drStu没有指定configName，则使用默认configName `main`。

　　对于Model的使用，不同的Model会自动找到其所属的AYRecord实例以及相关配置进行数据库操作。假如希望同一个Model能够切换到不同的数据源上使用，也极度方便，这种用法非常适合于不同数据源中的table拥有相同表结构的情况，开发者希望用同一个Model来操作这些相同表结构的table，以下是示例代码：

```objective-c
	//从默认数据库main中取出数据
   Student *stu = [[Student dao] findById:123];
	//将该记录保存到备份数据库中
   [[stu use:@"backupDatabase"] save];
```
　　上例中的代码，`[stu use:@"backupDatabase"]`方法切换数据源到`backupDatabase`并直接将数据保存起来。
### 特别注意
　　只有在同一个Model希望对应到多个数据源的table时才需要使用use方法，如果同一个Model唯一对应一个数据源的一个table，那么数据源的切换是自动的，无需使用use方法。

```objective-c
    //默认使用main数据库保存Student
    [stu save];
    //默认使用TeacherDatasource数据库保存Teacher
    [tea save];
```
　　对于AYDb+AYDbEntry的使用，数据源的切换需要使用AYDb *db = [AYDb use:configName]方法得到数据库操作对象，然后就可以进行数据库操作了，以下是代码示例：

```objective-c
   NSArray<AYDbEntry *> *teachers = [[AYDb use:@"backup"] find:@"select * from teacher"];
   NSArray<AYDbEntry *> *teachers = [[AYDb main] find:@"select * from teacher"];
```
　　以上两行代码，分别对应configName为`backup`、`main`的数据源中得到各自的数据库操作对象，然后就可以如同单数据源完全一样的方式来使用数据库操作API了。简言之，对于AYDb+AYDbEntry来说，多数据源相比单数据仅需多调用[AYDb use:]，随后的API使用方式完全一样。
> 注意：最先创建的AYDbContext实例(没有指定数据源名称)将会成为主数据源，可以使用[AYDb main]。

