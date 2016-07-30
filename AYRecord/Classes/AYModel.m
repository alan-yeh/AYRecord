//
//  AYDatabase.m
//  AYRecord
//
//  Created by Alan Yeh on 15/9/28.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "AYRecord_private.h"

@interface AYModel()
@property (nonatomic, strong) id<AYSetProtocol> modifyFlag;
@property (nonatomic, strong, readonly) AYTable *table;
@property (nonatomic, strong, readonly) AYDbConfig *config;
@property (nonatomic, strong, readonly) NSString *configName;
@end

@implementation AYModel{
    AYTable *_table;
    NSString *_configName;
}
@dynamic ID;

+ (instancetype)dao{
    //cache daos
    static NSMutableDictionary<NSString *, AYModel *> *daoMap;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        daoMap = [NSMutableDictionary new];
    });
    @synchronized(self) {
        AYModel *dao = [daoMap objectForKey:NSStringFromClass([self class])];
        if (dao == nil) {
            dao = [[self alloc] init];
            [daoMap setObject:dao forKey:NSStringFromClass(self.class)];
        }
        return dao;
    }
}

+ (instancetype)modelWithAttributes:(NSDictionary<NSString *, id> *)attrs{
    return [[self alloc] initWithAttributes:attrs];
}

- (instancetype)use:(NSString *)configName{
    _configName = [configName copy];
    return self;
}

- (NSString *)configName{
    NSString *transaction_config = [NSThread currentThread].threadDictionary[AYRecord_THREAD_TRANSACTION_CONFIG];
    if (transaction_config) {
        return transaction_config;
    }else{
        return _configName;
    }
}

- (AYDbConfig *)config{
    AYDbConfig *config;
    if (self.configName) {
        config = [AYDbKit configForName:self.configName];
        AYAssert(config, @"can not find config named: %@", self.configName);
    }else{
        config = [AYDbKit configForModel:self.class];
    }
    if (!config) {
        config = [AYDbKit brokenConfig];
    }
    return config;
}

- (AYTable *)table{
    returnValIf(_table, _table);
    _table = [AYDbKit tableForModel:self.class];
    
    returnValIf(_table, _table);
    
    static NSMutableDictionary *__table_cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __table_cache = [NSMutableDictionary new];
    });
    
    AYTable *table = [__table_cache objectForKey:NSStringFromClass(self.class)];
    returnValIf(_table, _table);
    
    table = [AYTable buildTableWithModel:self.class];
    [__table_cache setObject:table forKey:NSStringFromClass(self.class)];
    return table;
}

#pragma mark - Getter/Setter
- (id<AYSetProtocol>)modifyFlag{
    return _modifyFlag ?: ({_modifyFlag = [self.config.containerFactory createSet];});
}

- (void)setValue:(id)value forKey:(NSString *)aKey{
    if (!value) {
        [self removeValueForKey:aKey];
        return;
    }
    [self.modifyFlag addValue:aKey];
    [super setValue:value forKey:aKey];
}

- (void)setDictionary:(NSDictionary<NSString *,id> *)aDictionary{
    [super setDictionary:aDictionary];
}

- (void)putValue:(id)anObject forKey:(NSString *)aKey{
    [super setValue:anObject forKey:aKey];
}

- (void)putDictionary:(NSDictionary<NSString *, id> *)aDictionary{
    [super setDictionary:aDictionary];
}

- (void)removeValueForKey:(NSString *)aKey{
    [self.modifyFlag removeValue:aKey];
    [super removeValueForKey:aKey];
}

- (void)removeAllValues{
    [self.modifyFlag removeAllValues];
    [super removeAllValues];
}

#pragma mark - dynamic property getter/setter
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSString *property = NSStringFromSelector(aSelector);
    BOOL isSetter = [property hasPrefix:@"set"];
    if (isSetter) {
        property = [property substringFromIndex:3];
        property = [property substringToIndex:property.length - 1];
    }
    
    AYColumn *column = [self.table columnForName:property];
    
    if (column) {
        return isSetter ? column.convertor.setterSignature : column.convertor.getterSignature;
    }else{
        return [super methodSignatureForSelector:aSelector];
    }
}

- (id)forwardingTargetForSelector:(SEL)aSelector{
    return self;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    NSString *property = NSStringFromSelector(anInvocation.selector);
    BOOL isSetter = [property hasPrefix:@"set"];
    if (isSetter) {
        property = [property substringFromIndex:3];
        property = [property substringToIndex:property.length - 1];
    }
    
    AYColumn *column = [self.table columnForName:property];
    
    if (column) {
        if (isSetter) {
            void *buffer = calloc(1, anInvocation.methodSignature.frameLength);
            [anInvocation getArgument:buffer atIndex:2];
            
            id value = [column.convertor objectForBuffer:buffer];
            [self setValue:value forKey:column.name];
            free(buffer);
        }else{
            void *buffer = calloc(1, anInvocation.methodSignature.methodReturnLength);
            
            id value = [self valueForKey:column.name];
            // property value revise
            id newValue = [column.convertor getBuffer:buffer fromObject:value];
            doIf(newValue, [self putValue:newValue forKey:column.name]);
            
            [anInvocation setReturnValue:buffer];
            doIf(![anInvocation argumentsRetained], [anInvocation retainArguments]);
            free(buffer);
        }
    }else{
        [super forwardInvocation:anInvocation];
    }
}

- (id)objectForKeyedSubscript:(NSString *)key{
    return [self valueForKey:key];
}
@end

#pragma mark - implementation of Operation
@implementation AYModel(Operation)
- (BOOL)save{
    AYDbConnection *conn = [self.config getOpenedConnection];
    @try {
        AYDbStatement *statment = [conn prepareStatement:[AYSqlBuilder forSave:self.table attrs:self->_attrs]];
        BOOL result = [statment executeUpdate];
        if (!result) {
            NSLog(conn.lastErrorMessage, nil);
        }else{
            [self putValue:@([statment generatedKey]) forKey:self.table.key];
        }
        return result;
    }
    @finally {
        [self.config close:conn];
    }
}

- (BOOL)update{
    returnValIf(self.modifyFlag.count < 1, YES);
    returnValIf(self.modifyFlag.count == 1 && [self.modifyFlag contains:@"ID"], YES);
    
    id idValue = [self valueForKey:self.table.key];
    AYAssert(idValue && [idValue integerValue] > 0, @"You can't update model without Primary Key");
    
    AYSql *updateSql = [AYSqlBuilder forUpdate:self.table attrs:self->_attrs modifyFlag:[self.modifyFlag toSet]];
    return [self updateWithSql:updateSql];
}

- (BOOL)updateAll{
    [self.modifyFlag addValuesFormArray:[self allKeys]];
    return [self update];
}

- (BOOL)saveOrUpdate{
    AYSql *sql = [AYSqlBuilder forReplace:self.table attrs:self->_attrs];
    return [self updateWithSql:sql];
}

- (BOOL)delete{
    AYAssert([self valueForKey:self.table.key], @"You can't delete model without primary key value");
    return [self deleteById:self.ID];
}

- (BOOL)deleteById:(NSInteger)idValue{
    AYParameterAssert(idValue > 0);
    AYSql *deleteSql = [AYSqlBuilder forDelete:self.table byCondition:@"ID = ?" withArgs:@[@(idValue)]];
    return [self updateWithSql:deleteSql];
}

- (BOOL)deleteByCondition:(NSString *)condition, ...{
    AYParameterAssert(condition != nil && condition.length > 0);
    AYSql *deleteSql = [AYSqlBuilder forDelete:self.table byCondition:condition withArgs:va_array(condition)];
    return [self updateWithSql:deleteSql];
}

- (BOOL)deleteAll{
    return [self updateWithSql:[AYSqlBuilder forDelete:self.table byCondition:@"1 = 1" withArgs:nil]];
}

- (NSInteger)count{
    return [self countByCondition:@"1 = 1"];
}

- (NSInteger)countByCondition:(NSString *)condition, ...{
    NSNumber *num = [self queryOneWithSql:[AYSqlBuilder forRowCount:self.table byCondition:condition withArgs:va_array(condition)]];
    return [num integerValue];
}

#pragma mark - Update Models
- (BOOL)update:(NSString *)sql, ...{
    return [self updateWithSql:[AYSql buildSql:sql withArgs:va_array(sql)]];
}

- (BOOL)updateWithSql:(AYSql *)sql{
    AYDbConnection *conn = [self.config getOpenedConnection];
    @try {
        return [[conn prepareStatement:sql] executeUpdate];
    }
    @finally {
        [self.config close:conn];
    }
}

#pragma mark - Find Models
- (NSArray *)findWithSql:(AYSql *)sql{
    AYDbConnection *conn = [self.config getOpenedConnection];
    @try {
        AYQueryResultSet *resultSet = [[conn prepareStatement:sql] executeQuery];
        NSMutableArray<AYModel *> *results = [NSMutableArray new];
        for (NSDictionary<NSString *, id> *attrs in resultSet) {
            id item = [[self.class alloc] initWithAttributes:attrs];
            [results addObject:item];
        }
        return results;
    }
    @finally {
        [self.config close:conn];
    }
}

- (NSArray *)find:(NSString *)sql, ...{
    return [self findWithSql:[AYSql buildSql:sql withArgs:va_array(sql)]];
}

- (NSArray *)findByCondition:(NSString *)condition, ...{
    AYSql *sql = [AYSqlBuilder forFind:self.table columns:@"*" byCondition:condition withArgs:va_array(condition)];
    return [self findWithSql:sql];
}

- (id)findFirstByCondition:(NSString *)condition, ...{
    AYSql *sql = [AYSqlBuilder forFind:self.table columns:@"*" byCondition:condition withArgs:va_array(condition)];
    NSArray *result = [self findWithSql:sql];
    returnValIf(result.count, result[0]);
    return nil;
}

- (NSArray *)findAll{
    AYSql *sql = [AYSqlBuilder forFind:self.table columns:nil byCondition:nil withArgs:nil];
    return [self findWithSql:sql];
}

- (id)findById:(NSInteger)idValue{
    AYParameterAssert(idValue > 0);
    AYSql *sql = [AYSqlBuilder forFind:self.table columns:@"*" byCondition:@"ID = ?" withArgs:@[@(idValue)]];
    return [self findFirstWithSql:sql];
}

- (id)findById:(NSInteger)idValue loadColumns:(NSString *)columns{
    AYParameterAssert(idValue > 0);
    AYSql *sql = [AYSqlBuilder forFind:self.table columns:columns byCondition:@"ID = ?" withArgs:@[@(idValue)]];
    return [self findFirstWithSql:sql];
}

- (id)findFirst:(NSString *)sql, ...{
    NSArray *result = [self findWithSql:[AYSql buildSql:sql withArgs:va_array(sql)]];
    returnValIf([result count], result[0]);
    return nil;
}

- (id)findFirstWithSql:(AYSql *)sql{
    NSArray *result = [self findWithSql:sql];
    returnValIf(result.count, result[0]);
    return nil;
}

- (id)queryOneWithSql:(AYSql *)sql{
    AYDbConnection *conn = [self.config getOpenedConnection];
    @try {
        AYQueryResultSet *result = [[conn prepareStatement:sql] executeQuery];
        returnValIf(result.count < 1, nil);
        
        AYQueryResult *item = [result objectAtIndex:0];
        NSArray *keys = [item allKeys];
        AYAssert(keys.count > 0, @"No columns was queried.");
        AYAssert(keys.count < 2, @"Only ONE column can be queried.");
        return [item objectForKey:[keys objectAtIndex:0]];
    }
    @finally {
        [self.config close:conn];
    }
}

- (id)queryOne:(NSString *)sql, ...{
    return [self queryOneWithSql:[AYSql buildSql:sql withArgs:va_array(sql)]];
}


- (AYPage *)paginate:(NSInteger)pageIndex size:(NSInteger)pageSize withSelect:(NSString *)select where:(NSString *)where, ...{
    AYParameterAssert(pageIndex > 0 && pageSize > 0);
    NSInteger total;
    {
        total = [[self queryOneWithSql:[AYSql buildSql:[@"select count(1) " stringByAppendingString:where] withArgs:va_array(where)]] integerValue];
        returnValIf(total < 1, [AYPage pageWithArray:[NSArray new] index:0 size:0 total:0]);
    }
    
    AYSql *sql = [AYSqlBuilder forPaginateIndex:pageIndex size:pageSize withSelect:select where:where args:va_array(where)];
    NSArray<AYModel *> *result = [self findWithSql:sql];
    return [AYPage pageWithArray:result index:pageIndex size:pageSize total:total];
}
@end

@implementation AYModel (Sql)
- (AYSql *)saveSql{
    return [AYSqlBuilder forSave:self.table attrs:self->_attrs];
}

- (AYSql *)updateSql{
    AYAssert([self valueForKey:self.table.key], @"You can't update model without primary key value");
    return [AYSqlBuilder forUpdate:self.table attrs:self->_attrs modifyFlag:self.modifyFlag.toSet];
}

- (AYSql *)deleteSql{
    AYAssert([self valueForKey:self.table.key], @"You can't delete model without primary key value");
    return [AYSqlBuilder forDelete:self.table byCondition:@"ID = ?" withArgs:@[@(self.ID)]];
}

@end

#pragma mark - implementation of Configuration
@implementation AYModel(Configuration)
+ (NSString *)tableName{
    return NSStringFromClass([self class]);
}

+ (NSInteger)version{
    return 1;
}

+ (NSString *)propertyForColumn:(NSString *)column{
    return nil;
}

+ (NSArray<AYSql *> *)migrateForm:(NSInteger)oldVersion to:(NSInteger)newVersion{
    return nil;
}
@end
