//
//  AYDbContext.h
//  AYRecord
//
//  Created by yan on 16/2/6.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AYRecord/AYRecordDefines.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AYContainerFactory;
@protocol AYDbTypeConvertor;

@interface AYDbContext : NSObject
- (instancetype)init AYRecord_API_UNAVAILABLE("use initWithDatasource:forConfig: instead");
+ (instancetype)new AYRecord_API_UNAVAILABLE("use initWithDatasource:forConfig: instead");

- (instancetype)initWithDatasource:(NSString *)datasource;/**< user default config name 'main'. */
- (instancetype)initWithDatasource:(NSString *)datasource forConfig:(NSString *)configName NS_DESIGNATED_INITIALIZER;

@property (nonatomic, assign) BOOL showSql;/**< Show sql to console. Default NO. */
@property (nonatomic, strong) id<AYContainerFactory> containerFactory;/**< Default return AYCaseSensitiveContainerFactory. */
@property (nonatomic, copy, readonly) NSString *configName;/**< Config name. */
@property (nonatomic, copy, readonly) NSString *datasource;/**< File of sqlite database. Create database file if not exists. */

- (void)registerModel:(Class)model;/**< Register model to context. */
- (void)registerConvertor:(id<AYDbTypeConvertor>)convertor;/** Register type convertor to context. */
- (void)initialize;/**< Initialize this context. */
@end

NS_ASSUME_NONNULL_END