# AYRecord

[![CI Status](http://img.shields.io/travis/alan-yeh/AYRecord.svg?style=flat)](https://travis-ci.org/alan-yeh/AYRecord)
[![Version](https://img.shields.io/cocoapods/v/AYRecord.svg?style=flat)](http://cocoapods.org/pods/AYRecord)
[![License](https://img.shields.io/cocoapods/l/AYRecord.svg?style=flat)](http://cocoapods.org/pods/AYRecord)
[![Platform](https://img.shields.io/cocoapods/p/AYRecord.svg?style=flat)](http://cocoapods.org/pods/AYRecord)

## 引用
　　使用[CocoaPods](http://cocoapods.org)可以很方便地引入AYRecord。Podfile添加AYRecord的依赖。

```ruby
pod "AYRecord"
```

## 简介

　　之前写过一段时间服务器端，使用了[JFinal](http://www.jfinal.com)作为服务器开发框架，开发速度大大地加快。在开发的过程中，ActiveRecord的数据库访问操作也让我眼前一亮。由于我在iOS开发中也常使用到数据库，因此结合Objective-C的特性将ActiveRecord移植改造到iOS端，命名为AYRecord。

　　AYRecord使用起来极为简单，支持自动建表，自动升级表结构。同时，AYRecord支持多数据源，并发访问控制等。

## 文档
　　[使用文档](DOC.md)。

## 简单用例
　　首先，先演示一下，AYRecord的一些常规使用方法，再详细讲一下其它细节用法。

　　声明一个实体Student

```objective-c
@class Student;
//默认有一个名为ID的主键属性
@interface Student : AYDbModel<Student *>
@property (nonatomic, copy) NSString *name;/**< 姓名 */
@property (nonatomic, assign) int age;/**< 年龄 */
@property (nonatomic, retain) NSDate *born;/**< 出生年月 */
@end

@implementation Student
@dynamic name;
@dynamic age;
@dynamic born;
@end
```
　　以上代码已经完成了AYRecord初始化的80%的工作了，接下来演示如何进行查询。

　　AYDbModel的子类默认有一个单例静态方法`dao`，用于各类数据库操作。

```objective-c
    //查询出生日期在2002年5月9日之后的学生
    NSDate *date = [@"2002-05-09" ay_dateValue:@"yyyy-MM-dd"];
    NSArray<Student *> *results = [[Student dao] findByCondition:@"born > ?", date];
    
    //查询年龄在15岁以下的学生
    NSArray<Student *> *results = [[Student dao] findByCondition:@"age > ?", @15];//仅接受OC类型
    
    //查询出生日期在2002年5月9日之后的学生数量
    NSUInteger count = [[Student dao] countByCondition:@"born > ?", date];
    
    //分页查询
    AYDbPage<Student *> *stus = [[Student dao] paginate:1 size:10 withSelect:@"select * " where:@"from student where name like '张%%'"];
```
　　插入

```objective-c
    //单条插入
    Student *stu = [Student new];
    stu.name = @"张三";
    stu.age = 20;
    stu.born = [NSDate new];
    [stu save];
    
    //从Json到数据库
    NSString *jsonStr = @"{'name': '张三', 'age': 14, 'born': 1020873600}";
    NSDictionary *jsonDic = [jsonStr ay_jsonDictionary];
    Student *stu = [[Student alloc] initWithAttributes:jsonDic];
    [stu save];
```
　　删除

```objective-c
    //单条删除
    Student *stu = [[Student dao] findById:15];
    [stu delete];
    //按ID删除
    [[Student dao] deleteById:20];
    //按条件删除
    [[Student dao] deleteByCondition:@"name = ?", @"张三"];
```
　　更新

```objective-c
    stu.name = @"李四";
    [stu update];
```
## AYRecord初始化
　　好了，如果你看到了这里，说明你已经觉得这ORM框架还不错，可以继续深入了解。那么，接下来，我们再来完成一次完整初始化框架的工作。

　　再声明一个实体Teacher
>　　AYDbModel是数据表实体类的基类，是AYRecord的重要组成部分。数据库实体类要求继承于AYDbModel类，并且要求将数据库列数性声明为@dynamic。
>>没有声明@dynamic将不会保存到数据库中。

```objective-c
@class Teacher;

@interface Teacher : AYDbModel<Teacher *>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int age;
@end

@implementation Teacher
@dynamic name;
@dynamic age;
@end
```
　　声明AYDbContext，将实体类注册到上下文。

```objective-c
   //在Documents/db/database.db中建立数据库
   AYDbContext *context = [[AYDbContext alloc] initWithDatasource:[[[AYFile documents] child:@"db"] child:@"database.db"]];
   //是否输出SQL到控制台
   context.showSql = YES;
   [context registerModel:[Student class]];
   [context registerModel:[Teacher class]];
   [context initialize];
```
> 关于AYFile的相关操作，参考[AYFile](https://github.com/alan-yeh/AYFile)。

　　`- registerModel:(Class)model`方法建立了数据库表与Model的映射关系。

　　以上便是建立数据库的全部过程了。

## License

AYRecord is available under the MIT license. See the LICENSE file for more info.
