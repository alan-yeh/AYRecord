//
//  TypeCompatibleTest.m
//  AYRecord
//
//  Created by PoiSon on 16/7/30.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Student.h"

@interface TypeCompatibleTest : XCTestCase

@end

@implementation TypeCompatibleTest

+ (void)setUp{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *dbPath = [[docDir stringByAppendingPathComponent:@"db"] stringByAppendingPathComponent:@"database.db"];
    
    [[NSFileManager new] removeItemAtPath:dbPath error:nil];
    
    AYDbContext *context = [[AYDbContext alloc] initWithDatasource:dbPath];
    context.showSql = YES;
    [context registerModel:[Student class]];
    [context initialize];
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBaseTypeCompatible{
    Student *stu = [Student new];
    id data = [NSData data];
    
    XCTAssertThrows(stu.name = data, @"此处抛出类型转换异常");
}

- (void)testDateCompatible{
    NSDate *date = [NSDate date];
    Student *stu = [Student new];
    
    id dateValue = @(date.timeIntervalSince1970);
    stu.date = dateValue;
    
    NSDate *stuDate = stu.date;
    XCTAssert(stuDate.timeIntervalSince1970 == date.timeIntervalSince1970, @"此处应相等");
}
@end
