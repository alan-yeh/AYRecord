//
//  AYSql.m
//  AYRecord
//
//  Created by Alan Yeh on 15/10/22.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "AYRecord_private.h"

@implementation AYSql
+ (instancetype)buildSql:(NSString *)sql, ...{
    return [[self alloc] initWithSql:sql withArgs:va_array(sql)];
}

+ (instancetype)buildSql:(NSString *)sql withArgs:(NSArray<id> *)args{
    return [[self alloc] initWithSql:sql withArgs:args];
}

- (instancetype)initWithSql:(NSString *)sql withArgs:(NSArray<id> *)args{
    if (self = [super init]){
        self.sql = sql;
        self.args = args;
    }
    return self;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"<AYSql %p>:{ sql: \"%@\", args: ...<%@ objects>}", self, self.sql, @(self.args.count)];
}

- (NSString *)debugDescription{
    NSMutableString *args = [NSMutableString string];
    if (self.args.count > 0) {
        [args appendString:@"("];
        
        NSMutableString *argString = [NSMutableString new];
        for (id value in self.args) {
            doIf(argString.length, [argString appendString:@","]);
            [argString appendFormat:@"%@", value];
        }
        [args appendString:argString];
        [args appendString:@")"];
    }else{
        [args appendString:@"<0 objects>"];
    }
    
    return [NSString stringWithFormat:@"<AYSql %p>:\n{\n   sql: \"%@\",\n   args: %@\n}", self, self.sql, args];
}
@end
