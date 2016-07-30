//
//  AYDbKit.h
//  AYRecord
//
//  Created by Alan Yeh on 15/10/1.
//  Copyright © 2015年 Alan Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AYDbConfig;
@class AYTable;
@protocol AYTypeConvertor;

NS_ASSUME_NONNULL_BEGIN
@interface AYDbKit : NSObject

+ (AYDbConfig *)brokenConfig;
+ (AYDbConfig *)mainConfig;

#pragma mark -
+ (void)addConfig:(AYDbConfig *)config;
+ (void)addModel:(Class)model toConfigMapping:(AYDbConfig *)config;
+ (void)addModel:(Class)model toTableMapping:(AYTable *)table;

+ (AYDbConfig *)configForName:(NSString *)configName;
+ (AYDbConfig *)configForModel:(Class)model;
+ (AYTable *)tableForModel:(Class)model;
+ (AYTable *)tableForName:(NSString *)tableName;

#pragma mark -
+ (id<AYTypeConvertor>)convertorForType:(NSString *)typeEncoding;
+ (id<AYTypeConvertor>)convertorForObject:(id)obj;
+ (void)addConvertor:(id<AYTypeConvertor>)convertor;
@end
NS_ASSUME_NONNULL_END