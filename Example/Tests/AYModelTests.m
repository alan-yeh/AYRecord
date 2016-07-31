//
//  AYDbModelTests.m
//  AYRecord
//
//  Created by PoiSon on 16/7/30.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Student.h"
#import "Teacher.h"
#import "None.h"

@interface AYDbModelTests : XCTestCase

@end

@implementation AYDbModelTests
+ (void)setUp{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *dbPath = [[docDir stringByAppendingPathComponent:@"db"] stringByAppendingPathComponent:@"database.db"];
    
    [[NSFileManager new] removeItemAtPath:dbPath error:nil];
    
    AYDbContext *context = [[AYDbContext alloc] initWithDatasource:dbPath];
    //    record.showSql = YES;
    [context registerModel:[Student class]];
    [context initialize];
    
    NSMutableArray<AYDbSql *> *inserts = [NSMutableArray arrayWithCapacity:20];
    for (NSInteger i = 0; i < 20; i ++) {
        [inserts addObject:[AYDbSql buildSql:@"insert into student(name, age) values(?, ?)", [NSString stringWithFormat:@"张%@", @(i)], @(i)]];
    }
    NSAssert([[AYDb main] batchSqls:inserts], @"batch fail");
}

+ (void)tearDown{
    [[Student dao] deleteAll];
}
- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/** 测试添加. */
- (void)testSave{
    Student *newStu = [Student new];
    [newStu setValue:@"张三" forKey:@"name"];
    [newStu setValue:@(14) forKey:@"age"];
    XCTAssert([newStu save], @"保存失败");
    XCTAssertNotNil([newStu valueForKey:@"ID"], @"没有自动生成ID");
}
/** 测试更新. */
- (void)testUpdate{
    NSArray<Student *> *students = [[Student dao] findAll];
    XCTAssert(students.count, @"查询不到数据");
    Student *aStu = students[0];
    [aStu setValue:@"王五" forKey:@"name"];
    XCTAssert([aStu update], @"更新失败");
    Student *updatedStu = [[Student dao] findById:aStu.ID];
    XCTAssert(updatedStu, @"无法查找到已更新的数据");
    XCTAssert([[updatedStu stringValueForKey:@"name"] isEqualToString:@"王五"], @"更新后数据不对应");
}
/** 测试删除. */
- (void)testDelete{
    NSArray<Student *> *students = [[Student dao] findAll];
    XCTAssert(students.count, @"查询不到数据");
    Student *aStu = students[0];
    XCTAssert([aStu delete], @"删除失败");
    Student *deletedStu = [[Student dao] findById:aStu.ID];
    XCTAssertNil(deletedStu, @"删除后数据仍存在");
}

/** 测试删除. */
- (void)testDeleteById{
    NSArray<Student *> *students = [[Student dao] findAll];
    XCTAssert(students.count, @"查询不到数据");
    Student *aStu = students[0];
    XCTAssert([[Student dao] deleteById:aStu.ID], @"删除失败");
    Student *deletedStu = [[Student dao] findById:aStu.ID];
    XCTAssertNil(deletedStu, @"删除后数据仍存在");
}
/** 测试查询. */
- (void)testFind{
    NSArray<Student *> *stus1 = [[Student dao] find:@"select * from student where 1 = ?", @(1)];
    XCTAssert(stus1.count, @"查询不到数据");
    
    NSArray<Student *> *stus2 = [[Student dao] find:@"select * from student where name like ?", @"张%"];
    XCTAssert(stus2.count, @"查询不到数据");
}
/** 测试查询. */
- (void)testFindFirst{
    Student *aStu = [[Student dao] findFirst:@"select * from student limit 1"];
    XCTAssertNotNil(aStu, @"查询不到数据");
    
    Student *aStu2 = [[Student dao] findFirst:@"select * from student"];
    XCTAssertNotNil(aStu2, @"查询不到数据");
    
    Student *aStu3 = [[Student dao] findFirst:@"select * from student where 1 = 0"];
    XCTAssertNil(aStu3, @"此处应该查不到数据");
}
/** 测试查询. */
- (void)testFindById{
    NSArray<Student *> *students = [[Student dao] findAll];
    XCTAssert(students.count, @"查询不到数据");
    Student *aStu = students[0];
    Student *findedStu = [[Student dao] findById:aStu.ID];
    XCTAssert(aStu != findedStu, @"对象引用地址不能一样");
    XCTAssert([aStu isEqual:findedStu], @"记录的内容不一样");
}

- (void)testFindByCondition{
    NSArray<Student *> *student = [[Student dao] findByCondition:@"age > ? and age < ?", @(5), @(10)];
    XCTAssert(student.count, @"查询不到数据");
}

- (void)testFindFirstByCondition{
    Student *stu = [[Student dao] findFirstByCondition:@"1 = 0"];
    XCTAssertNil(stu, @"此处应该查不到数据");
}
/** 测试查询. */
- (void)testFindByIdLoadColumn{
    NSArray<Student *> *students = [[Student dao] findAll];
    XCTAssert(students.count, @"查询不到数据");
    Student *aStu = students[0];
    Student *findedStu = [[Student dao] findById:aStu.ID loadColumns:@"id, name"];
    XCTAssert(aStu != findedStu, @"对象引用地址不能一样");
    XCTAssert(aStu.ID == findedStu.ID, @"记录的ID不一样");
    XCTAssert([findedStu allKeys].count == 2, @"查询的列数与预期不同");
}
/** 测试分页. */
- (void)testPage{
    AYDbPage<Student *> *page = [[Student dao] paginate:1 size:10 withSelect:@"select *" where:@"from Student where 1 = ?", @(1)];
    XCTAssertNotNil(page, @"返回值不能为空");
    XCTAssert(page.list, @"返回值不能为空");
    XCTAssert(page.list.count, @"记录不能为空");
    XCTAssert(page.pageIndex == 1, @"当前分页期望为1");
    XCTAssert(page.pageSize == 10, @"当前分页大小期望为10");
}


//- (void)testPerformanceInsert{
//    [self measureBlock:^{
//        [[AYDb main] tx:^BOOL(AYDb * _Nonnull db) {
//            for (NSUInteger i = 0; i < 3000; i ++) {
//                Student *newStu = [Student new];
//                [newStu setValue:[NSString stringWithFormat:@"张%@", @(i)] forKey:@"name"];
//                [newStu setValue:@(1) forKey:@"age"];
//                [newStu save];
//            }
//            return YES;
//        }];
//    }];
//}
//
//- (void)testPerformanceInsert2{
//    [self measureBlock:^{
//        [[AYDb main] tx:^BOOL(AYDb * _Nonnull db) {
//            for (NSUInteger i = 0; i < 3000; i ++) {
//                Student *newStu = [Student new];
//                [newStu setValue:[NSString stringWithFormat:@"张%@", @(i)] forKey:@"name"];
//                [newStu setValue:@(1) forKey:@"age"];
//                [newStu save];
//            }
//            return YES;
//        }];
//    }];
//}
//
//- (void)testPerformanceSelect{
//    [[Student dao] deleteAll];
//    NSMutableArray<AYDbSql *> *inserts = [NSMutableArray arrayWithCapacity:20];
//    for (NSInteger i = 0; i < 3000; i ++) {
//        [inserts addObject:[AYDbSql buildSql:@"insert into student(name, age) values(?, ?)", [NSString stringWithFormat:@"张%@", @(i)], @(i)]];
//    }
//    [[AYDb new] batchSqls:inserts];
//    [self measureBlock:^{
//        [[Student dao] findAll];
//    }];
//}

- (void)testNoneRegister{
    None *none = [None new];
    none.age = 10;
    none.name = @"123";
    
    id age = [none valueForKey:@"age"];
    XCTAssert([age isKindOfClass:[NSNumber class]]);
    XCTAssert([age intValue] == 10);
    
    id name = [none valueForKey:@"name"];
    XCTAssert([name isEqualToString:@"123"]);
}
@end
