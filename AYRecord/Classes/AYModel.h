//
//  AYDatabase.h
//  AYRecord
//
//  Created by Alan Yeh on 15/9/28.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <AYRecord/AYDbAttribute.h>

@class AYPage<M>;
@class AYSql;

NS_ASSUME_NONNULL_BEGIN
/**
 *  Table Mapping
 */
@interface AYModel<M> : AYDbAttribute
@property (nonatomic, assign) NSInteger ID;/**< default column, primary key. */

+ (instancetype)dao;/**< Data Access Object. DO NOT use it to store info.*/

+ (instancetype)modelWithAttributes:(NSDictionary<NSString *, id> *)attrs;

- (NSString *)configName;/**< Return config name of current datasource. */
- (instancetype)use:(NSString *)configName;/**< Switching datasource. */

#pragma mark - Getter/Setter
- (void)setValue:(nullable id)value forKey:(NSString *)aKey;/**< Set value for key to the model. throws when table dose not contians the key. */
- (void)setDictionary:(NSDictionary<NSString *,id> *)aDictionary;/**< Set value pair form ${aDictionary}. throws when table dose not contains the key in ${aDictionary}. */
- (void)putValue:(id)value forKey:(NSString *)aKey;/**< Put value for key to the model without check attribute name. */
- (void)putDictionary:(NSDictionary<NSString *, id> *)aDictionary;/**< Put key value pair from ${aDictionary} without check attribute name. */

- (nullable id)objectForKeyedSubscript:(NSString *)key;
@end

/**
 *  Provide methods to visit database.
 */
@interface AYModel<M>(Operation)
- (BOOL)save;/**< Save model. */
- (BOOL)update;/**< Update model. */
- (BOOL)updateAll;/**< Update all attributes. */
- (BOOL)saveOrUpdate;/**< Save model if not exists. Update model if exists. User "replace into" */
- (BOOL)delete;/**< Delete model. */
- (BOOL)deleteById:(NSInteger)idValue;/**< Delete model by idValue.*/
- (BOOL)deleteByCondition:(NSString *)condition, ...;/**< Delete model by condition. */
- (BOOL)deleteAll;/**< Clear all record in table. */

- (NSInteger)count;/**< Row count of table. */
- (NSInteger)countByCondition:(NSString *)condition, ...;/**< Row count of Record. */

#pragma mark - Update Models
- (BOOL)update:(NSString *)sql, ...;/**< Execute update, insert or delete sql statement. */
- (BOOL)updateWithSql:(AYSql *)sq;/**< Execute update, insert or delete sql statement. */

#pragma mark - Find Models
- (NSArray<M> *)find:(NSString *)sql, ...;/**< Find models. */
- (NSArray<M> *)findWithSql:(AYSql *)sql;/**< Find models. */
- (NSArray<M> *)findByCondition:(NSString *)condition, ...;/**< Find model with condition. [[Model dao] findWithCondition:@"age > ? and weight < ?", @30, @100] */
- (nullable M)findFirstByCondition:(NSString *)condition, ...;/**< Find first model. I recomment add "limit 1" in your conditions. */
- (NSArray<M> *)findAll;/**< Find all model in table. */
- (nullable M)findFirst:(NSString *)sql, ...;/**< Find first model. I recomment add "limit 1" in your sql. */
- (nullable M)findFirstWithSql:(AYSql *)sql;/**< Find first model. I recomment add "limit 1" in your sql. */
- (nullable M)findById:(NSInteger)idValue;/**< Find model by id. */
- (nullable M)findById:(NSInteger)idValue loadColumns:(NSString *)columns;/**< Find model by id and load specific columns only. */
- (id)queryOne:(NSString *)sql, ...;/**< Execute sql query just return one column.*/
- (id)queryOneWithSql:(AYSql *)sql;/**< Execute sql query just return one column.*/
/**
 *  Paginate.
 *
 *  @param pageIndex the page index. start with 1.
 *  @param pageSize  the page size
 *  @param select    the select part of the sql statement
 *  @param where     the sql statement excluded select part and the parameters of sql.
 *
 */
- (AYPage<M> *)paginate:(NSInteger)pageIndex size:(NSInteger)pageSize withSelect:(NSString *)select where:(NSString *)where, ...;
@end

@interface AYModel<M> (Sql)
- (AYSql *)saveSql;/**< Get sql of save operation.*/
- (AYSql *)updateSql;/**< Get sql of update operation. */
- (AYSql *)deleteSql;/**< Get sql of delete operation. */
@end

/**
 *  Config table.
 */
@interface AYModel<M>(Configuration)
+ (NSString *)tableName;/**< Return table name of the model. default is class name. */
+ (NSInteger)version;/**< Return current version of the model. default is 1.*/
+ (NSString *)propertyForColumn:(NSString *)column;/**< Return property of column. */
+ (NSArray<AYSql *> *)migrateForm:(NSInteger)oldVersion to:(NSInteger)newVersion;/**< Return sqls for migration. default is nil.*/
@end
NS_ASSUME_NONNULL_END