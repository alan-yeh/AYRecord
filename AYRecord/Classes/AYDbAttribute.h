//
//  AYDbAttribute.h
//  AYRecord
//
//  Created by Alan Yeh on 15/10/23.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AYDictionaryProtocol;

NS_ASSUME_NONNULL_BEGIN
@interface AYDbAttribute : NSObject<NSCopying>{
    @public
    id<AYDictionaryProtocol> _attrs;
}
- (instancetype)initWithAttributes:(NSDictionary<NSString *, id> *)attributes;/**< Initializate a model with attributes. */

- (void)processContainerWithConfig:(NSString *)config;/**< process this model to the config. */

- (NSDictionary<NSString *, id> *)attributes;/**< Get attributes of this model. */

- (void)removeValueForKey:(NSString *)key;/**< Remove attribute from this model. */
- (void)removeAllValues;/**< Remove all attribute form this model. */

#pragma mark - Setter
- (void)setValue:(nullable id)value forKey:(NSString *)key;/**< Set attribute to model. */
- (void)setDictionary:(NSDictionary<NSString *, id> *)aDictionary;/**< Set attribute from ${aDictionary} to model. */

#pragma mark - Getter
- (NSArray<NSString *> *)allKeys;/**< Return all keys of this model. */
- (nullable id)valueForKey:(NSString *)aKey;/**< Get value for key. */
- (nullable id)valueForKey:(NSString *)aKey useDefault:(id (^)())defaultValue;/**< Get value for key. Return defaultValue when value is nil. */

#pragma mark -
/* Get oc value. throws when value can not convert. */
- (nullable NSString *)stringValueForKey:(NSString *)aKey;
- (nullable NSData *)dataValueForKey:(NSString *)aKey;

/* Get c value. throws when value can not convert. */
- (short)shortValueForKey:(NSString *)aKey;
- (unsigned short)unsignedShortValueForKey:(NSString *)aKey;
- (int)intValueForKey:(NSString *)aKey;
- (unsigned int)unsignedIntValueForKey:(NSString *)aKey;
- (long)longValueForKey:(NSString *)aKey;
- (unsigned long)unsignedLongValueForKey:(NSString *)aKey;
- (long long)longLongValueForKey:(NSString *)aKey;
- (unsigned long long)unsignedLongLongValueForKey:(NSString *)aKey;
- (float)floatValueForKey:(NSString *)aKey;
- (double)doubleValueForKey:(NSString *)aKey;
- (BOOL)boolValueForKey:(NSString *)aKey;
- (NSInteger)integerValueForKey:(NSString *)aKey;
- (NSUInteger)unsignedIntegerValueForKey:(NSString *)aKey;
@end
NS_ASSUME_NONNULL_END