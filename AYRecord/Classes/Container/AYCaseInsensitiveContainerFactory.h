//
//  AYCaseInsensitiveContainerFactory.h
//  AYRecord
//
//  Created by Alan Yeh on 15/10/24.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AYRecord/AYContainerFactory.h>
#import <AYRecord/AYDictionaryProtocol.h>
#import <AYRecord/AYSetProtocol.h>

NS_ASSUME_NONNULL_BEGIN
@class AYCaseInsensitiveSet<ValueType: NSString *>;
@class AYCaseInsensitiveDictionary;

@interface AYCaseInsensitiveContainerFactory : NSObject<AYContainerFactory>
- (AYCaseInsensitiveSet<NSString *> *)createSet;

- (AYCaseInsensitiveDictionary *)createDictionary;
@end


@interface AYCaseInsensitiveDictionary<ValueType> : NSObject<AYDictionaryProtocol>
- (NSArray<NSString *> *)allKeys;
- (NSDictionary<NSString *,id> *)toDictionary;

- (void)setValue:(nullable ValueType)value forKey:(NSString *)aKey;
- (void)setDictionary:(NSDictionary<NSString *, ValueType> *)aDictionary;
- (void)removeValueForKey:(NSString *)aKey;
- (nullable ValueType)valueForKey:(NSString *)aKey;
@end

@interface AYCaseInsensitiveSet<ValueType : NSString *> : NSObject<AYSetProtocol>
- (NSSet<ValueType> *)toSet;

- (void)addValue:(ValueType)value;
- (void)addValuesFormSet:(NSSet<ValueType> *)set;
- (void)addValuesFormArray:(NSArray<ValueType> *)array;
- (void)removeValue:(ValueType)value;

- (BOOL)contains:(ValueType)value;
@end

NS_ASSUME_NONNULL_END