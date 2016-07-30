//
//  AYDbConfig.m
//  AYRecord
//
//  Created by Alan Yeh on 15/9/28.
//  Copyright © 2015年 Alan Yeh. All rights reserved.
//

#import "AYRecord_private.h"

@interface AYDbConfig()

@end

@implementation AYDbConfig{
    /** thread safe transaction connection*/
    AYDbConnection *_transConnection;
    AYDbConnection *_connection;
    NSRecursiveLock *_lock;
}

- (instancetype)initWithName:(NSString *)name datasource:(NSString *)datasource{
    if (self = [super init]) {
        _name = [name copy];
        _datasource = [datasource copy];
        _transConnection = nil;
        _lock = [NSRecursiveLock new];
        _connection = [[AYDbConnection alloc] initWithDatasource:_datasource];
    }
    return self;
}

- (id<AYContainerFactory>)containerFactory{
    return _containerFactory?: [AYCaseSensitiveContainerFactory new];
}

- (AYDbConnection *)getOpenedConnection{
    [_lock lock];
    AYAssert(_connection, @"can not open sqlite, please check whether if AYRecord started.");
    [_connection open];
    return _connection;
}

- (void)setTransactionConnection:(AYDbConnection *)connection{
    AYAssert(!_transConnection, @"can not reopen a transaction.");
    [NSThread currentThread].threadDictionary[AYRecord_THREAD_TRANSACTION_CONFIG] = self.name;
    _transConnection = connection;
}

- (void)removeTransactionConnection{
    _transConnection = nil;
    [[NSThread currentThread].threadDictionary removeObjectForKey:AYRecord_THREAD_TRANSACTION_CONFIG];
}

- (void)close:(AYDbConnection *)conn{
    @try {
        if (_transConnection == nil) {
            AYAssert([conn close], @"can not close connection: %@.", conn);
        }
    }
    @finally {
        [_lock unlock];
    }
}

- (BOOL)isInTransaction{
    return _transConnection != nil;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"<AYDbConfig %p>:\n{\n   name : %@\n   containerFactory : %@\n   isInTransaction : %@\n   datasource : %@\n}\n", self, self.name, NSStringFromClass([self.containerFactory class]), self.isInTransaction ?@"YES": @"NO", self.datasource];
}
@end
