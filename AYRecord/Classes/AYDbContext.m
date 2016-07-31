//
//  AYDbContext.m
//  AYRecord
//
//  Created by yan on 16/2/6.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import "AYRecord_private.h"


@implementation AYDbContext{
    NSMutableArray *_registedModel;
}

- (instancetype)initWithDatasource:(NSString *)dataSource{
    return [self initWithDatasource:dataSource forConfig:@"main"];
}

- (nonnull instancetype)initWithDatasource:(nonnull NSString*)datasource forConfig:(nonnull NSString *)configName{
    AYAssert(datasource.length, @"datasource can not be nil or empty");
    AYAssert(configName.length, @"configName can not be nil or empty");
    if (self = [super init]) {
        _registedModel = [NSMutableArray new];
        
        _datasource = datasource;
        _configName = configName;
    }
    return self;
}

- (NSString *)description{
    NSMutableString *result = [NSMutableString new];
    for (id value in _registedModel) {
        doIf(result.length, [result appendString:@","]);
        [result appendFormat:@"%@", value];
    }
    
    return [NSString stringWithFormat:@"<AYRecord %p>:\n{\n   Models : %@\n   Datasource : %@\n}", [super description], result, self.datasource];
}

- (NSString *)debugDescription{
    NSMutableString *result = [NSMutableString new];
    for (id value in _registedModel) {
        doIf(result.length, [result appendString:@","]);
        [result appendFormat:@"%@", value];
    }
    return [NSString stringWithFormat:@"<AYRecord %p>:\n{\n   Models : %@\n   Datasource : %@\n}", [super description], result, self.datasource];
}

- (id<AYContainerFactory>)containerFactory{
    return _containerFactory?: [AYCaseSensitiveContainerFactory new];
}

- (void)registerModel:(Class)model{
    AYParameterAssert([model isSubclassOfClass:[AYDbModel class]]);
    [_registedModel addObject:model];
}

- (void)registerConvertor:(id<AYDbTypeConvertor>)convertor{
    AYParameterAssert([convertor conformsToProtocol:@protocol(AYDbTypeConvertor)]);
    [AYDbKit addConvertor:convertor];
}

- (void)createPathIfNotExists{
    NSString *databasePath = [self.datasource stringByDeletingLastPathComponent];
    NSFileManager *manager = [NSFileManager new];
    
    if ([manager fileExistsAtPath:databasePath]) {
        return ;
    }else{
        [manager createDirectoryAtPath:databasePath
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];
    }
}

- (void)initialize{
    AYAssert(self.datasource.length, @"you must set up a database");
    AYAssert(_registedModel.count, @"you must register one model at lease");
    [AYDbConnection showSqls:self.showSql];
    
    //Auto create path
    [self createPathIfNotExists];
    
    AYDbConfig *config = [[AYDbConfig alloc] initWithName:self.configName datasource:self.datasource];
    config.containerFactory = self.containerFactory;
    
    [AYDbKit addModel:[AYDbTable class] toConfigMapping:config];
    [AYDbKit addModel:[AYDbColumn class] toConfigMapping:config];
    [AYDbKit addConfig:config];
    
    NSDictionary<NSString *, AYDbTable *> *tableConfig = [self buildTableConfig:config];
    BOOL result = [[AYDb use:config.name] tx:^BOOL(AYDb * db){
        for (Class model in _registedModel) {
            NSString *tableName = [model tableName];
            AYDbTable *tableStruct = [tableConfig objectForKey:tableName];
            
            if (!tableStruct) {
                //create table
                tableStruct = [AYDbTable buildTableWithModel:model];
                AYAssert([db updateWithSql:[AYDbSqlBuilder forCreate:tableStruct]], @"execute creation failed");
                AYAssert([db batchSqls:[model migrateForm:0 to:tableStruct.version]], @"execute migration failed");
                AYAssert([tableStruct save], @"save table info for %@ failed", NSStringFromClass(model));
            }else{
                //update table
                AYAssert(tableStruct.type == model, @"init AYRecord fail cause conflict between %@ and %@", NSStringFromClass(tableStruct.type), NSStringFromClass(model));
                AYDbTable *currentStruct = [AYDbTable buildTableWithModel:model];
                
                if (tableStruct.version < currentStruct.version) {
                    
                    NSArray<AYDbEntry *> *records = [db find:[NSString stringWithFormat:@"pragma table_info ('%@')", currentStruct.name]];
                    
                    NSMutableArray<NSString *> *existedColumns = [NSMutableArray new];
                    for (AYDbEntry *record in records) {
                        [existedColumns addObject:[[record valueForKey:@"name"] lowercaseString]];
                    }
                    
                    //find new columns
                    NSMutableArray<AYDbColumn *> *newColumns = [NSMutableArray new];
                    for (AYDbColumn *column in currentStruct.cols) {
                        if (![tableStruct.cols containsObject:column] && ![existedColumns containsObject:column.name.lowercaseString]) {
                            [newColumns addObject:column];
                        }
                    }
                    
                    //build add column sqls
                    NSMutableArray<AYDbSql *> *addSqls = [NSMutableArray new];
                    for (AYDbColumn *column in newColumns) {
                        [addSqls addObject:[AYDbSqlBuilder forAddColumn:column toTable:currentStruct]];
                    }
                    
                    AYAssert([db batchSqls:addSqls], @"add columns failed");
                    
                    //execute migration
                    AYAssert([db batchSqls:[model migrateForm:tableStruct.version to:currentStruct.version]], @"execute migration failed");
                    
                    //add new column structure
                    currentStruct.ID = tableStruct.ID;
                    AYAssert([currentStruct updateAll], @"update table structure failed");
                    tableStruct = currentStruct;
                }
            }
            [AYDbKit addModel:model toConfigMapping:config];
            [AYDbKit addModel:model toTableMapping:tableStruct];
        }
        return YES;
    }];
    AYAssert(result, @"Initialize failed.");
}

- (NSDictionary<NSString *, AYDbTable *> *)buildTableConfig:(AYDbConfig *)config{
    // initialize
    AYDb *db = [AYDb use:config.name];
    
    AYDbTable *configTable = [AYDbTable buildTableWithModel:AYDbTable.class];
    [AYDbKit addModel:AYDbTable.class toTableMapping:configTable];
    AYAssert([db updateWithSql:[AYDbSqlBuilder forCreate:configTable]], @"unable to create config table");
    
    NSMutableDictionary<NSString *, AYDbTable *> *result = [NSMutableDictionary new];
    for (AYDbTable *table in [[AYDbTable dao] findAll]) {
        [result setObject:table forKey:[table name]];
    }
    return result;
}
@end
