//
//  AYDbConfig.h
//  AYRecord
//
//  Created by Alan Yeh on 15/9/28.
//  Copyright © 2015年 Alan Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AYDbConnection;
@protocol AYContainerFactory;
NS_ASSUME_NONNULL_BEGIN
@interface AYDbConfig : NSObject
- (nonnull instancetype)initWithName:(nonnull NSString *)name datasource:(nonnull NSString *)datasource;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *datasource;
@property (nonatomic, strong) id<AYContainerFactory> containerFactory;

#pragma mark - Transaction
@property (nonatomic, assign, readonly) BOOL isInTransaction;
- (void)setTransactionConnection:(AYDbConnection *)connection;/**< set up a common connection to begin a transaction. */
- (void)removeTransactionConnection;/**< remove the common connection to complete a transaction. */
- (AYDbConnection *)getOpenedConnection;/**< get a connection, this connection may be a transaction connection. */
- (void)close:(AYDbConnection *)conn;/**< close a connection. */
@end
NS_ASSUME_NONNULL_END