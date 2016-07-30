//
//  assert.h
//  AYRecord
//
//  Created by yan on 16/2/7.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AYAssert(condition, desc, ...) \
    do { \
        __PRAGMA_PUSH_NO_EXTRA_ARG_WARNINGS \
        if (!(condition)) {		\
            @throw [AYDbError errorInMethod: _cmd \
                                     object: self \
                                       file: __FILE__ \
                                       line: __LINE__ \
                                description: desc, ##__VA_ARGS__]; \
        } \
        __PRAGMA_POP_NO_EXTRA_ARG_WARNINGS \
    } while(0)

#define AYParameterAssert(condition) AYAssert((condition), @"Invalid parameter not satisfying: %@", @#condition)

#define AYDbAssert(condition, err_msg, err_code, err_sql, err_ds) \
    do { \
        __PRAGMA_PUSH_NO_EXTRA_ARG_WARNINGS \
        if (!(condition)) {		\
            @throw [AYDbError errorInMethod: _cmd \
                                     object: self \
                                       file: __FILE__ \
                                       line: __LINE__ \
                                      error: err_msg \
                                       code: err_code \
                                        sql: err_sql \
                                 datasource: err_ds]; \
        } \
        __PRAGMA_POP_NO_EXTRA_ARG_WARNINGS \
    } while(0)

@interface AYDbError : NSObject
+ (NSError *)errorInMethod:(SEL)method object:(id)obj file:(const char *)file line:(NSUInteger)line description:(NSString *)desc, ...;
+ (NSError *)errorInMethod:(SEL)method object:(id)obj file:(const char *)file line:(NSUInteger)line error:(NSString *)error code:(id)code sql:(id)sql datasource:(NSString *)datasource;
@end