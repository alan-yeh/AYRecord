//
//  AYDbSql.h
//  AYRecord
//
//  Created by Alan Yeh on 15/10/22.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface AYDbSql : NSObject
+ (instancetype)buildSql:(NSString *)sql, ...;
+ (instancetype)buildSql:(NSString *)sql withArgs:(NSArray<id> *)args;

@property (nonatomic, copy) NSString *sql;
@property (nonatomic, copy, nullable) NSArray<id> *args;
@end
NS_ASSUME_NONNULL_END