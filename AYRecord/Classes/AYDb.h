//
//  AYDb.h
//  AYRecord
//
//  Created by Alan Yeh on 15/9/30.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class AYDbPage<M>;
@class AYDbSql;
@class AYDbEntry;

/**
 *  AYDb
 *  <p/>
 *  Database query and update tool.
 */
@interface AYDb : NSObject
- (NSString *)configName;/**< Return config name of current datasource */
+ (instancetype)use:(nullable NSString *)configName;/**< Change default datasource. Use default datasource if nil. */
+ (instancetype)main;/**< Use main datasource. */

- (nullable id)queryOne:(NSString *)sql, ...;/**< Execute sql query just return one column.*/
- (nullable id)queryOneWithSql:(AYDbSql *)sql;/**< Execute sql query just return one column.*/
- (BOOL)update:(NSString *)sql, ...;/**< Execute update, insert or delete sql statement. */
- (BOOL)updateWithSql:(AYDbSql *)sql;/**< Execute update, insert or delete sql statement. */
- (BOOL)tx:(BOOL (^)(AYDb *db))transaction;/**< Execute transaction. */
- (BOOL)batch:(NSArray<NSString *> *)sqls;/**< Execute a batch of sqls. */
- (BOOL)batchSqls:(NSArray<AYDbSql *> *)sqls;/**< Execute a batch of sqls. */
/**
 *  Paginate.
 *
 *  @param pageIndex the page index, start with 1
 *  @param pageSize  the page size
 *  @param select    the select part of the sql statement
 *  @param where     the sql statement excluded select part and the parameters of sql.
 *
 *  @return AYDbPage<AYDbEntry *> *
 */
- (AYDbPage<AYDbEntry *> *)paginate:(NSInteger)pageIndex size:(NSInteger)pageSize withSelect:(NSString *)select where:(NSString *)where, ...;
@end

@interface AYDb(Record)
- (NSArray<AYDbEntry *> *)find:(NSString *)sql, ...;/**< Find records. */
- (NSArray<AYDbEntry *> *)findWithSql:(AYDbSql *)sql;/**< Find records. */
- (nullable AYDbEntry *)findFirst:(NSString *)sql, ...;/**< Find first record. I recommend add "limit 1" in your sql. */
- (nullable AYDbEntry *)findFirstWithSql:(AYDbSql *)sql;/**< Find first record. I recommend add "limit 1" in your sql. */
@end
NS_ASSUME_NONNULL_END
