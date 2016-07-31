//
//  AYDictionaryProtocol.h
//  AYRecord
//
//  Created by Alan Yeh on 15/10/24.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol AYDictionaryProtocol <NSObject, NSFastEnumeration>
- (nonnull NSArray<NSString *> *)allKeys;
- (nonnull NSDictionary<NSString *, id> *)toDictionary;

- (void)setValue:(nullable id)value forKey:(nonnull NSString *)aKey;
- (void)setDictionary:(nonnull NSDictionary<NSString *, id> *)aDictionary;
- (void)removeValueForKey:(nonnull NSString *)aKey;
- (void)removeAllValues;
- (nullable id)valueForKey:(nonnull NSString *)aKey;

- (BOOL)isEqual:(nonnull id<AYDictionaryProtocol>)object;
@end