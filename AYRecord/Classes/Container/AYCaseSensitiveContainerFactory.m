//
//  AYCaseSensitiveContainerFactory.m
//  AYRecord
//
//  Created by Alan Yeh on 15/10/24.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "AYCaseSensitiveContainerFactory.h"
#import "convenientmacros.h"

@implementation AYCaseSensitiveContainerFactory
- (AYCaseSensitiveSet<NSString *> *)createSet{
    return [AYCaseSensitiveSet new];
}

- (AYCaseSensitiveDictionary *)createDictionary{
    return [AYCaseSensitiveDictionary new];
}
@end


#pragma mark - AYCaseSensitiveDictionary
@interface AYCaseSensitiveDictionary()
@property (nonatomic, strong) NSMutableDictionary *valuePair;
@end

@implementation AYCaseSensitiveDictionary
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
    [self.valuePair setObject:value forKey:key];
}

- (void)setDictionary:(NSDictionary *)aDictionary{
    [self.valuePair setDictionary:aDictionary];}

- (void)removeValueForKey:(NSString *)aKey{
    [self.valuePair removeObjectForKey:aKey];
}

- (void)removeAllValues{
    [self.valuePair removeAllObjects];
}

- (id)valueForKey:(NSString *)aKey{
    return [self.valuePair objectForKey:aKey];
}

- (BOOL)isEqual:(AYCaseSensitiveDictionary *)object{
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

#pragma mark - AYCaseSensitiveSet
@interface AYCaseSensitiveSet()
@property (nonatomic, strong) NSMutableSet *values;
@end

@implementation AYCaseSensitiveSet
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
    [self.values addObject:value];
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
    [self.values removeObject:value];
}

- (void)removeAllValues{
    [self.values removeAllObjects];
}

- (BOOL)contains:(id)value{
    return [self.values containsObject:value];
}

- (BOOL)isEqual:(AYCaseSensitiveSet *)object{
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