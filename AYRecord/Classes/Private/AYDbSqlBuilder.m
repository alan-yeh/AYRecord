//
//  AYSQLBuilder.m
//  AYRecord
//
//  Created by Alan Yeh on 15/9/28.
//  Copyright © 2015年 Alan Yeh. All rights reserved.
//

#import "AYRecord_private.h"

@implementation AYDbSqlBuilder
+ (AYDbSql *)forCreate:(AYDbTable *)table{
    NSMutableString *createSql = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT", table.name];
    for (AYDbColumn *column in table.cols) {
        continueIf([column.name.lowercaseString isEqualToString:@"ID".lowercaseString]);
        [createSql appendFormat:@", %@ %@", column.name, column.convertor.dataType];
        
        NSString *columnProperty = [table.type propertyForColumn:column.name];
        if (columnProperty.length > 0) {
            [createSql appendFormat:@" %@", columnProperty];
        }
    }
    [createSql appendString:@")"];
    return [AYDbSql buildSql:createSql];
}

+ (AYDbSql *)forAddColumn:(AYDbColumn *)column toTable:(AYDbTable *)table{
    NSMutableString *addSql = [NSMutableString stringWithFormat:@"ALTER TABLE %@ ADD %@ %@", table.name, column.name, column.convertor.dataType];
    NSString *columnProperty = [table.type propertyForColumn:column.name];
    if (columnProperty.length > 0) {
        [addSql appendFormat:@" %@", columnProperty];
    }
    return [AYDbSql buildSql:addSql];
}

+ (AYDbSql *)forRowCount:(AYDbTable *)table byCondition:(NSString *)condition withArgs:(NSArray<id> *)args{
    NSMutableString *rowCountSql = [NSMutableString stringWithFormat:@"SELECT COUNT(1) FROM %@", table.name];
    if (condition.length > 0) {
        [rowCountSql appendString:@" WHERE "];
        [rowCountSql appendString:condition];
    }
    return [AYDbSql buildSql:rowCountSql withArgs:args];
}

+ (AYDbSql *)forSave:(AYDbTable *)table attrs:(id<AYDictionaryProtocol>)attrs{
    NSMutableArray *params = [NSMutableArray new];
    NSMutableString *sqlStr = [NSMutableString stringWithFormat:@"INSERT INTO %@ (", table.name];
    NSMutableString *args = [[NSMutableString alloc] initWithString:@") VALUES("];
    BOOL isFirst = YES;
    for (NSString *attrKey in attrs) {
        continueIf(![table hasColumn:attrKey]);

        if (!isFirst) {
            [sqlStr appendString:@", "];
            [args appendString:@", "];
        }
        [sqlStr appendString:attrKey];
        [args appendString:@"?"];
        [params addObject:[attrs valueForKey:attrKey]];
        isFirst = NO;
    }
    [sqlStr appendString:args];
    [sqlStr appendString:@")"];
    return [AYDbSql buildSql:sqlStr withArgs:params];
}

+ (AYDbSql *)forUpdate:(AYDbTable *)table attrs:(id<AYDictionaryProtocol>)attrs modifyFlag:(NSSet<NSString *> *)modifyFlags{
    NSMutableArray *params = [NSMutableArray new];
    NSMutableString *sqlStr = [NSMutableString stringWithFormat:@"UPDATE %@ SET ", table.name];
    
    BOOL isUpdatable = NO;
    for (NSString *modifyColumn in modifyFlags) {
        continueIf(![table hasColumn:modifyColumn]);
        continueIf([table.key isEqualToString:modifyColumn]);
        
        doIf(isUpdatable, [sqlStr appendString:@", "]);
        
        [sqlStr appendFormat:@"%@ = ?", modifyColumn];
        [params addObject:[attrs valueForKey:modifyColumn]];
        isUpdatable = YES;
    }
    
    AYAssert(isUpdatable, @"none attrs are updatable.");
    
    [sqlStr appendFormat:@" WHERE %@ = ?", table.key];
    id idValue = [attrs valueForKey:table.key];
    AYAssert(idValue, @"can't find primark key in model.");
    [params addObject:idValue];
    
    return [AYDbSql buildSql:sqlStr withArgs:params];
}

+ (AYDbSql *)forReplace:(AYDbTable *)table attrs:(id<AYDictionaryProtocol>)attrs{
    NSMutableArray *params = [NSMutableArray new];
    NSMutableString *sqlStr = [NSMutableString stringWithFormat:@"REPLACE INTO %@ (", table.name];
    NSMutableString *args = [[NSMutableString alloc] initWithString:@") VALUES("];
    BOOL isFirst = YES;
    for (NSString *attrKey in attrs) {
        continueIf(![table hasColumn:attrKey]);
        
        if (!isFirst) {
            [sqlStr appendString:@", "];
            [args appendString:@", "];
        }
        
        [sqlStr appendString:attrKey];
        [args appendString:@"?"];
        [params addObject:[attrs valueForKey:attrKey]];
        isFirst = NO;
    }
    [sqlStr appendString:args];
    [sqlStr appendString:@")"];
    return [AYDbSql buildSql:sqlStr withArgs:params];
}

+ (AYDbSql *)forDelete:(AYDbTable *)table byCondition:(NSString *)condition withArgs:(NSArray<id> *)args{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"DELETE FROM %@", table.name];
    if (condition.length) {
        [sql appendString:@" WHERE "];
        [sql appendString:condition];
    }
    return [AYDbSql buildSql:sql withArgs:args];
}

+ (AYDbSql *)forFind:(AYDbTable *)table columns:(NSString *)columns byCondition:(NSString *)condition withArgs:(NSArray<id> *)args{
    NSMutableString *sql = [NSMutableString stringWithString:@"SELECT "];
    if (columns.length > 0) {
        [sql appendString:columns];
    }else{
        NSMutableString *cols = [NSMutableString new];
        for (AYDbColumn *column in table.cols) {
            doIf(cols.length, [cols appendString:@", "]);
            [cols appendFormat:@"%@", column.name];
        }
        
        [sql appendString:cols];
    }
    [sql appendFormat:@" FROM %@", table.name];
    
    if (condition.length > 0) {
        [sql appendFormat:@" WHERE %@", condition];
    }
    return [AYDbSql buildSql:sql withArgs:args];
}

+ (AYDbSql *)forPaginateIndex:(NSInteger)pageIndex size:(NSInteger)pageSize withSelect:(NSString *)select where:(NSString *)where args:(NSArray *)args{
    NSInteger offset = pageSize * (pageIndex - 1);
    NSString *sql = [NSString stringWithFormat:@"%@ %@ LIMIT %@ OFFSET %@", select, where, @(pageSize), @(offset)];
    return [AYDbSql buildSql:sql withArgs:args];
}
@end
