//
//  AYDbTests.m
//  AYRecord
//
//  Created by Alan Yeh on 16/7/30.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Student.h"

@interface AYDbTests : XCTestCase

@end

@implementation AYDbTests

+ (void)setUp{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *dbPath = [[docDir stringByAppendingPathComponent:@"db"] stringByAppendingPathComponent:@"database.db"];
    
    [[NSFileManager new] removeItemAtPath:dbPath error:nil];
    
    AYDbContext *context = [[AYDbContext alloc] initWithDatasource:dbPath];
    context.showSql = YES;
    [context registerModel:[Student class]];
    [context initialize];
    
    NSMutableArray<AYDbSql *> *inserts = [NSMutableArray arrayWithCapacity:20];
    for (NSInteger i = 0; i < 20; i ++) {
        [inserts addObject:[AYDbSql buildSql:@"insert into student(name, age) values(?, ?)", [NSString stringWithFormat:@"张%@", @(i)], @(i)]];
    }
    NSAssert([[AYDb main] batchSqls:inserts], @"batch fail");
}

- (void)testUse{
    XCTAssertThrows([AYDb use:@"abc"], @"期望抛异常");
    AYDb *db = [AYDb use:nil];
    XCTAssertNotNil(db);
}
/** 测试查询. */
- (void)testQueryOne{
    NSNumber *count = [[AYDb main] queryOne:@"select count(1) from student"];
    XCTAssertNotNil(count);
    XCTAssertThrows([[AYDb main] queryOne:@"select * from student"]);
}
/** 测试查询. */
- (void)testUpdate{
    int count = [[AYDb main] update:@"update student set name = '张三' where name = ?", @"张3"];
    XCTAssertEqual(count, 1, @"更新数目不一致");
}

/** 测试查找. */
- (void)testFindRecords{
    NSArray *results = [[AYDb main] find:@"select * from student where 1 = ?", @(1)];
    XCTAssert(results.count);
}
- (void)testFindFistRecord{
    AYDbEntry *aStu1 = [[AYDb main] findFirst:@"select * from student where 1 = ?", @(1)];
    XCTAssertNotNil(aStu1);
    
    AYDbEntry *aStu2 = [[AYDb main] findFirst:@"select * from student where 1 = ? limit 1", @(1)];
    XCTAssertNotNil(aStu2);
}

- (void)testPage{
    AYDbPage *page = [[AYDb main] paginate:1 size:10 withSelect:@"select *" where:@"from student where 1 = ?", @(1)];
    XCTAssertNotNil(page);
    XCTAssertEqual(page.pageSize, 10);
    XCTAssertEqual(page.pageIndex, 1);
    XCTAssert(page.totalRow > page.pageSize);
    XCTAssert(page.totalPage > 1);
}

//- (void)testPerformanceInsert{
//    NSMutableArray *inserts = [NSMutableArray arrayWithCapacity:20];
//    for (NSInteger i = 0; i < 1200; i ++) {
//        [inserts addObject:format(@"insert into student(name, age) values('张%@', %@)", @(i), @(i))];
//    }
//    [self measureBlock:^{
//        [[AYDb new] batch:inserts];
//    }];
//}

@end
