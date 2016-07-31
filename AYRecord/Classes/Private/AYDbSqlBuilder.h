//
//  AYSQLBuilder.h
//  AYRecord
//
//  Created by Alan Yeh on 15/9/28.
//  Copyright © 2015年 Alan Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AYDbTable;
@class AYDbColumn;
@class AYDbSql;
@protocol AYSetProtocol;
@protocol AYDictionaryProtocol;

NS_ASSUME_NONNULL_BEGIN
@interface AYDbSqlBuilder : NSObject
+ (AYDbSql *)forCreate:(AYDbTable *)table;
+ (AYDbSql *)forAddColumn:(AYDbColumn *)column toTable:(AYDbTable *)table;
+ (AYDbSql *)forRowCount:(AYDbTable *)table byCondition:(NSString *)condition withArgs:(nullable NSArray<id> *)args;
+ (AYDbSql *)forSave:(AYDbTable *)table attrs:(id<AYDictionaryProtocol>)attrs;
+ (AYDbSql *)forUpdate:(AYDbTable *)table attrs:(id<AYDictionaryProtocol>)attrs modifyFlag:(NSSet<NSString *> *)modifyFlags;
+ (AYDbSql *)forReplace:(AYDbTable *)table attrs:(id<AYDictionaryProtocol>)attrs;
+ (AYDbSql *)forDelete:(AYDbTable *)table byCondition:(nullable NSString *)condition withArgs:(nullable NSArray<id> *)args;
+ (AYDbSql *)forFind:(AYDbTable *)table columns:(nullable NSString *)columns byCondition:(nullable NSString *)condition withArgs:(nullable NSArray<id> *)args;
+ (AYDbSql *)forPaginateIndex:(NSInteger)pageIndex size:(NSInteger)pageSize withSelect:(NSString *)select where:(nullable NSString *)where args:(nullable NSArray<id> *)args;
@end

NS_ASSUME_NONNULL_END