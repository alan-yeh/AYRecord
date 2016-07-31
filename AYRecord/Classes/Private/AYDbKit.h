//
//  AYDbKit.h
//  AYRecord
//
//  Created by Alan Yeh on 15/10/1.
//  Copyright © 2015年 Alan Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AYDbConfig;
@class AYDbTable;
@protocol AYDbTypeConvertor;

NS_ASSUME_NONNULL_BEGIN
@interface AYDbKit : NSObject

+ (AYDbConfig *)brokenConfig;
+ (AYDbConfig *)mainConfig;

#pragma mark -
+ (void)addConfig:(AYDbConfig *)config;
+ (void)addModel:(Class)model toConfigMapping:(AYDbConfig *)config;
+ (void)addModel:(Class)model toTableMapping:(AYDbTable *)table;

+ (AYDbConfig *)configForName:(NSString *)configName;
+ (AYDbConfig *)configForModel:(Class)model;
+ (AYDbTable *)tableForModel:(Class)model;
+ (AYDbTable *)tableForName:(NSString *)tableName;

#pragma mark -
+ (id<AYDbTypeConvertor>)convertorForType:(NSString *)typeEncoding;
+ (id<AYDbTypeConvertor>)convertorForObject:(id)obj;
+ (void)addConvertor:(id<AYDbTypeConvertor>)convertor;
@end
NS_ASSUME_NONNULL_END