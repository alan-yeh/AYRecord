//
//  AYSQLBuilder.h
//  AYRecord
//
//  Created by Alan Yeh on 15/9/28.
//  Copyright © 2015年 Alan Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AYTable;
@class AYColumn;
@class AYSql;
@protocol AYSetProtocol;
@protocol AYDictionaryProtocol;

NS_ASSUME_NONNULL_BEGIN
@interface AYSqlBuilder : NSObject
+ (AYSql *)forCreate:(AYTable *)table;
+ (AYSql *)forAddColumn:(AYColumn *)column toTable:(AYTable *)table;
+ (AYSql *)forRowCount:(AYTable *)table byCondition:(NSString *)condition withArgs:(nullable NSArray<id> *)args;
+ (AYSql *)forSave:(AYTable *)table attrs:(id<AYDictionaryProtocol>)attrs;
+ (AYSql *)forUpdate:(AYTable *)table attrs:(id<AYDictionaryProtocol>)attrs modifyFlag:(NSSet<NSString *> *)modifyFlags;
+ (AYSql *)forReplace:(AYTable *)table attrs:(id<AYDictionaryProtocol>)attrs;
+ (AYSql *)forDelete:(AYTable *)table byCondition:(nullable NSString *)condition withArgs:(nullable NSArray<id> *)args;
+ (AYSql *)forFind:(AYTable *)table columns:(nullable NSString *)columns byCondition:(nullable NSString *)condition withArgs:(nullable NSArray<id> *)args;
+ (AYSql *)forPaginateIndex:(NSInteger)pageIndex size:(NSInteger)pageSize withSelect:(NSString *)select where:(nullable NSString *)where args:(nullable NSArray<id> *)args;
@end

NS_ASSUME_NONNULL_END