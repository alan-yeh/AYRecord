//
//  AYDbConnection.h
//  AYRecord
//
//  Created by Alan Yeh on 15/10/18.
//  Copyright © 2015年 Alan Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSDictionary<NSString *, id> AYQueryResult;
typedef NSArray<NSDictionary<NSString *, id> *> AYQueryResultSet;
@class AYSql;
@protocol AYTypeConvertor;

NS_ASSUME_NONNULL_BEGIN
@interface AYDbConnection : NSObject
+ (void)showSqls:(BOOL)showSql;

@property (nonatomic, copy, readonly) NSString *datasource;
- (instancetype)initWithDatasource:(NSString *)datasource NS_DESIGNATED_INITIALIZER;

- (BOOL)open;/**< connect to database. */
- (BOOL)close;/**< disconnect to database.*/
- (BOOL)isClosed;/**< whether is closed. */
- (int)lastErrorCode;/**< last execution error code. */
- (nullable NSString *)lastErrorMessage;/**< last execution error message. */
@end

@class AYDbStatement;
/**
 *  Make prepared statement
 */
@interface AYDbConnection(Statement)
- (nullable AYDbStatement *)prepareStatement:(AYSql *)sql;
@end

@interface AYDbConnection(Transaction)
- (BOOL)isInTransaction;/**< whether currently in a transaction or not. */
- (void)beginTransaction;/**< Begin a transaction. */
- (void)commit;/**< Commit a transaction. */
- (void)rollback;/**< Rollback a transaction. */
@end

@interface AYDbStatement : NSObject
#pragma mark - query
- (AYQueryResultSet *)executeQuery;/**< execute querable sql. */

#pragma mark - update
- (BOOL)executeUpdate;/**< execute updatable sql. */
- (long long int)generatedKey;/**< get generated primary key when execute a insert sql. */
@end
NS_ASSUME_NONNULL_END