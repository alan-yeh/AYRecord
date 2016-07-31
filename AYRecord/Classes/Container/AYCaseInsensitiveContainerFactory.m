//
//  AYCaseInsensitiveContainerFactory.m
//  AYRecord
//
//  Created by Alan Yeh on 15/10/24.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import "AYCaseInsensitiveContainerFactory.h"

@implementation AYCaseInsensitiveContainerFactory
- (AYCaseInsensitiveSet<NSString *> *)createSet{
    return [AYCaseInsensitiveSet new];
}

- (AYCaseInsensitiveDictionary *)createDictionary{
    return [AYCaseInsensitiveDictionary new];
}
@end


#pragma mark - AYCaseInsensitiveDictionary
@interface AYCaseInsensitiveDictionary()
@property (nonatomic, strong) NSMutableDictionary *valuePair;
@end

@implementation AYCaseInsensitiveDictionary
- (NSMutableDictionary *)valuePair{
    return _valuePair ?: ({_valuePair = [NSMutableDictionary new];});
}

- (NSArray<NSString *> *)allKeys{
    return [_valuePair allKeys];
}

- (NSDictionary<NSString *,id> *)toDictionary{
    return [_valuePair copy];
}

- (void)setValue:(id)value forKey:(NSString *)key{
    [self.valuePair setObject:value forKey:key.lowercaseString];
}

- (void)setDictionary:(NSDictionary *)aDictionary{
    [aDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self.valuePair setValue:obj forKey:[key lowercaseString]];
    }];
}

- (void)removeValueForKey:(NSString *)aKey{
    [self.valuePair removeObjectForKey:aKey.lowercaseString];
}

- (void)removeAllValues{
    [self.valuePair removeAllObjects];
}

- (id)valueForKey:(NSString *)aKey{
    return [self.valuePair objectForKey:aKey.lowercaseString];
}

- (BOOL)isEqual:(AYCaseInsensitiveDictionary *)object{
    if ([NSStringFromClass(self.class) isEqualToString:NSStringFromClass([object class])]) {
        return [self.valuePair isEqualToDictionary:object.valuePair];
    }
    return NO;
}

- (NSUInteger)hash{
    return self.valuePair.hash;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id  _Nonnull *)buffer count:(NSUInteger)len{
    return [self.valuePair countByEnumeratingWithState:state objects:buffer count:len];
}
@end

#pragma mark - AYCaseInsensitiveSet
@interface AYCaseInsensitiveSet()
@property (nonatomic, strong) NSMutableSet *values;
@end

@implementation AYCaseInsensitiveSet
- (NSMutableSet *)values{
    return _values ?: ({_values = [NSMutableSet new];});
}

- (NSUInteger)count{
    return self.values.count;
}

- (NSSet *)toSet{
    return [self.values copy];
}

- (void)addValue:(id)value{
    [self.values addObject:[value lowercaseString]];
}

- (void)addValuesFormSet:(NSSet *)set{
    for (NSString *obj in set) {
        [self addValue:obj];
    }
}

- (void)addValuesFormArray:(NSArray *)array{
    for (NSString *obj in array) {
        [self addValue:obj];
    }
}

- (void)removeValue:(id)value{
    [self.values removeObject:[value lowercaseString]];
}

- (void)removeAllValues{
    [self.values removeAllObjects];
}

- (BOOL)contains:(NSString *)value{
    return [self.values containsObject:value.lowercaseString];
}

- (BOOL)isEqual:(AYCaseInsensitiveSet *)object{
    if ([NSStringFromClass(self.class) isEqualToString:NSStringFromClass([object class])]) {
        return [self.values isEqualToSet:object.values];
    }
    return NO;
}

- (NSUInteger)hash{
    return self.values.hash;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id  _Nonnull *)buffer count:(NSUInteger)len{
    return [self.values countByEnumeratingWithState:state objects:buffer count:len];
}
@end