//
//  AYDb.m
//  AYRecord
//
//  Created by Alan Yeh on 15/9/30.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import "AYRecord_private.h"

@interface AYDb()
@end

@implementation AYDb{
    AYDbConfig *_config;
    AYDbConnection *_tansConn;
}

- (instancetype)initWithConfig:(AYDbConfig *)config{
    if (self = [super init]) {
        AYAssert(config, @"can not set up a nil config");
        _config = config;
    }
    return self;
}

- (instancetype)init{
    AYDbConfig *config = [AYDbKit mainConfig];
    AYAssert(config, @"The main config is nil, initialize AYRecord first");
    return [self initWithConfig:config];
}

+ (instancetype)use:(NSString *)configName{
    if (configName.length) {
        AYDbConfig *config = [AYDbKit configForName:configName];
        AYAssert(config, @"Config not found by configName: ", configName);
        return [[self alloc] initWithConfig:config];
    }else{
        return [self main];
    }
}

// singleton to prevent repeat allocation.
+ (instancetype)main{
    static AYDb *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (NSString *)configName{
    return _config.name;
}

#pragma mark -
- (id)queryOne:(NSString *)sql, ...{
    return [self queryOneWithSql:[AYDbSql buildSql:sql withArgs:va_array(sql)]];
}

- (id)queryOneWithSql:(AYDbSql *)sql{
    AYDbConnection *conn = [_config getOpenedConnection];
    @try {
        AYQueryResultSet *result = [[conn prepareStatement:sql] executeQuery];
        returnValIf(result.count < 1, nil);
        
        AYQueryResult *item = [result objectAtIndex:0];
        NSArray *values = [item allValues];
        AYAssert(values.count > 0, @"No columns was queried.");
        AYAssert(values.count < 2, @"Only ONE column can be queried.");
        return [values[0] isKindOfClass:[NSNull class]] ? nil : values[0];
    }
    @finally {
        [_config close:conn];
    }
}

- (BOOL)update:(NSString *)sql, ...{
    return [self updateWithSql:[AYDbSql buildSql:sql withArgs:va_array(sql)]];
}

- (BOOL)updateWithSql:(AYDbSql *)sql{
    AYDbConnection *conn = [_config getOpenedConnection];
    @try {
        return [[conn prepareStatement:sql] executeUpdate];
    }
    @finally {
        [_config close:conn];
    }
}

- (BOOL)tx:(BOOL (^)(AYDb *))transaction{
    AYDbConnection *conn = [_config getOpenedConnection];
    [_config setTransactionConnection:conn];
    [conn beginTransaction];
    BOOL result = NO;
    @try {
        result = transaction(self);
        if (result) {
            [conn commit];
        }else{
            [conn rollback];
        }
        return result;
    }
    @catch (id error) {
        [conn rollback];
        @throw error;
    }
    @finally {
        [_config removeTransactionConnection];
        [_config close:conn];
    }
}

- (BOOL)batch:(NSArray<NSString *> *)sqls{
    NSMutableArray<AYDbSql *> *sqlArray = [NSMutableArray new];
    for (NSString *sql in sqls) {
        [sqlArray addObject:[AYDbSql buildSql:sql]];
    }
    return [self batchSqls:sqlArray];
}

- (BOOL)batchSqls:(NSArray<AYDbSql *> *)sqls{
    if (sqls.count < 1) {
        return YES;
    }
    
    AYDbConnection *conn = [_config getOpenedConnection];
    BOOL isInTransaction = _config.isInTransaction;
    
    doIf(!isInTransaction, ({
        [_config setTransactionConnection:conn];
        [conn beginTransaction];
    }));
    
    @try {
        for (AYDbSql *sql in sqls) {
            AYAssert([[conn prepareStatement:sql] executeUpdate], conn.lastErrorMessage, nil);
        }
        doIf(!isInTransaction, [conn commit]);
        return YES;
    }
    @catch (id error) {
        doIf(!isInTransaction, [conn rollback]);
        @throw error;
    }
    @finally {
        doIf(!isInTransaction, ({
            [_config removeTransactionConnection];
        }));
        [_config close:conn];
    }
}

- (AYDbPage<AYDbEntry *> *)paginate:(NSInteger)pageIndex size:(NSInteger)pageSize withSelect:(NSString *)select where:(NSString *)where, ...{
    AYAssert(pageIndex > 0 && pageSize > 0, @"pageIndex and pageSize must be more than 0");
    
    NSInteger total;
    {
        total = [[self queryOneWithSql:[AYDbSql buildSql:[@"select count(1) " stringByAppendingString:where] withArgs:va_array(where)]] integerValue];
        returnValIf(total < 1, [AYDbPage pageWithArray:[NSArray new] index:0 size:0 total:0]);
    }
    
    AYDbSql *sql = [AYDbSqlBuilder forPaginateIndex:pageIndex size:pageSize withSelect:select where:where args:va_array(where)];
    NSArray<AYDbEntry *> *result = [self findWithSql:sql];
    return [AYDbPage pageWithArray:result index:pageIndex size:pageSize total:total];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"<AYDb %p>:\n{\n   config name: %@\n   datasource: %@\n}", self, _config.name, _config.datasource];
}
@end

#pragma mark -
@implementation AYDb(Record)
- (NSArray<AYDbEntry *> *)find:(NSString *)sql, ...{
    return [self findWithSql:[AYDbSql buildSql:sql withArgs:va_array(sql)]];
}

- (NSArray<AYDbEntry *> *)findWithSql:(AYDbSql *)sql{
    AYDbConnection *conn = [_config getOpenedConnection];
    @try {
        AYQueryResultSet *result = [[conn prepareStatement:sql] executeQuery];
        NSMutableArray<AYDbEntry *> *records = [NSMutableArray new];
        [result enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [records addObject:[[AYDbEntry alloc] initWithAttributes:obj]];
        }];
        return records;
    }
    @finally {
        [_config close:conn];
    }
}

- (AYDbEntry *)findFirst:(NSString *)sql, ...{
    NSArray *result = [self findWithSql:[AYDbSql buildSql:sql withArgs:va_array(sql)]];
    returnValIf(result.count, result[0]);
    return nil;
}

- (AYDbEntry *)findFirstWithSql:(AYDbSql *)sql{
    NSArray *result = [self findWithSql:sql];
    returnValIf(result.count, result[0]);
    return nil;
}
@end
