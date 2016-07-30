//
//  assert.m
//  AYRecord
//
//  Created by yan on 16/2/7.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import "AYAssert.h"
#import "objc.h"
#import "AYRecordDefines.h"

AYRecord_EXTERN_STRING_IMP(AYRecordErrorFunction)
AYRecord_EXTERN_STRING_IMP(AYRecordErrorFile)
AYRecord_EXTERN_STRING_IMP(AYRecordErrorLine)

@implementation AYDbError
+ (NSError *)errorInMethod:(SEL)method object:(id)obj file:(const char *)file line:(NSUInteger)line description:(NSString *)desc, ...{
    va_list va;
    va_start(va, desc);
    va_end(va);
    NSString *description = [[NSString alloc] initWithFormat:desc arguments:va];
    
    NSString *fileName = [@(file) lastPathComponent];
    
    sql_printf(@"%@ %@: %@\nAYRecord: %@\n", [[self formatter] stringFromDate:[NSDate date]], fileName, @(line), description);
    
    return [NSError errorWithDomain:@"cn.yerl.AYRecord"
                               code:-1000
                           userInfo:@{NSLocalizedDescriptionKey: description,
                                      AYRecordErrorFunction: NSStringFromSelector(method),
                                      AYRecordErrorFile: fileName,
                                      AYRecordErrorLine: @(line)}];
}

+ (NSError *)errorInMethod:(SEL)method object:(id)obj file:(const char *)file line:(NSUInteger)line error:(NSString *)error code:(id)code sql:(id)sql datasource:(NSString *)datasource{
    NSString *fileName = [@(file) lastPathComponent];
    
    NSString *desc = [NSString stringWithFormat:@"%@ %@: %@\nAYRecord: %@\n{\n   Error code: %@,\n   Sql: %@,\n   Datasource: %@\n}\n", [[self formatter] stringFromDate:[NSDate date]], fileName, @(line), error, code, sql, datasource];
    
    sql_printf(desc);
    
    return [NSError errorWithDomain:@"cn.yerl.AYRecord"
                               code:-1000
                           userInfo:@{NSLocalizedDescriptionKey: desc,
                                      AYRecordErrorFunction: NSStringFromSelector(method),
                                      AYRecordErrorFile: fileName,
                                      AYRecordErrorLine: @(line)}];
}

+ (NSDateFormatter *)formatter{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
    });
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    return formatter;
}

@end