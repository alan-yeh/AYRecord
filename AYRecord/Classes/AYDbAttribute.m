//
//  AYDbAttribute.m
//  AYRecord
//
//  Created by Alan Yeh on 15/10/23.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "AYRecord_private.h"

@interface AYDbAttribute()
@property (nonatomic, nonnull, strong) id<AYDictionaryProtocol> attrs;
@end

@implementation AYDbAttribute{
    AYDbConfig *_config;
}
- (id)copyWithZone:(NSZone *)zone{
    return [[self.class allocWithZone:zone] initWithAttributes:[self.attrs toDictionary]];
}

- (instancetype)init{
    return self = [self initWithAttributes:[NSDictionary new]];
}

- (instancetype)initWithAttributes:(NSDictionary<NSString *,id> *)attributes{
    if (self = [super init]) {
        [self.attrs setDictionary:attributes];
    }
    return self;
}

- (void)processContainerWithConfig:(NSString *)config{
    _config = [AYDbKit configForName:config];
    AYAssert(_config, @"can't find config named %@", config);
    id<AYDictionaryProtocol> newAttrs = [_config.containerFactory createDictionary];
    [newAttrs setDictionary:[self.attrs toDictionary]];
    _attrs = newAttrs;
}

- (id<AYDictionaryProtocol>)attrs{
    return _attrs ?: ({_attrs = [self.config.containerFactory createDictionary];});
}

- (AYDbConfig *)config{
    return _config ?: ({_config = [AYDbKit mainConfig] ?: [AYDbKit brokenConfig];});
}

- (NSDictionary<NSString *,id> *)attributes{
    return [self.attrs toDictionary];
}


- (NSString *)description{
    NSMutableString *attrDescs = [NSMutableString string];
    
    NSDictionary<NSString *, id> *dic = [self.attrs toDictionary];
    for (NSString *key in dic) {
        id value = dic[key];
        id valueDesc = [value isKindOfClass:[NSData class]] ? [NSString stringWithFormat:@"<NSData %p>", value] : value;
        [attrDescs appendFormat:@" %@ : %@,", key, valueDesc];
    }
    return [NSString stringWithFormat:@"<%@ %p>:{%@}", [self class], self, [attrDescs substringToIndex:attrDescs.length - 1]];
}

- (BOOL)isEqual:(AYDbEntry *)object{
    returnValIf(![object isKindOfClass:self.class], NO);
    return [self.attrs isEqual:object.attrs];
}

- (NSUInteger)hash{
    return [self.attrs hash];
}

#pragma mark - Getter/Setter
- (void)setValue:(id)value forKey:(NSString *)aKey{
    [self willChangeValueForKey:aKey];
    if (!value) {
        [self removeValueForKey:aKey];
        return;
    }
    [self.attrs setValue:value forKey:aKey];
    [self didChangeValueForKey:aKey];
}

- (void)setDictionary:(NSDictionary<NSString *,id> *)aDictionary{
    for (NSString *key in aDictionary) {
        [self setValue:aDictionary[key] forKey:key];
    }
}

- (void)removeValueForKey:(NSString *)aKey{
    [self willChangeValueForKey:aKey];
    [self.attrs removeValueForKey:aKey];
    [self didChangeValueForKey:aKey];
}

- (void)removeAllValues{
    for (NSString *key in self.attrs) {
        [self removeValueForKey:key];
    }
}

- (NSArray<NSString *> *)allKeys{
    return [self.attrs allKeys];
}

- (id)valueForKey:(NSString *)aKey{
    id value = [self.attrs valueForKey:aKey];
    returnValIf(value == nil || [value isKindOfClass:[NSNull class]], nil);
    return value;
}

- (id)valueForKey:(NSString *)aKey useDefault:(id (^)())defaultValue{
    id value = [self.attrs valueForKey:aKey];
    doIf([value isKindOfClass:[NSNull class]], value = nil);
    return value?: defaultValue();
}

#define CONVERT_OC_TYPE_AND_RETURN(type) \
    id value = [self.attrs valueForKey:aKey]; \
    id<AYTypeConvertor> convertor = [AYDbKit convertorForType:[NSString stringWithFormat:@"@\"%s\"", #type]]; \
    __unsafe_unretained type *result; \
    [convertor getBuffer:&result fromObject:value]; \
    return result;

- (NSString *)stringValueForKey:(NSString *)aKey{
    CONVERT_OC_TYPE_AND_RETURN(NSString);
}

- (NSData *)dataValueForKey:(NSString *)aKey{
    CONVERT_OC_TYPE_AND_RETURN(NSData);
}
#undef CONVERT_OC_TYPE_AND_RETURN

#define CONVERT_TYPE_AND_RETURN(type) \
    id value = [self.attrs valueForKey:aKey]; \
    id<AYTypeConvertor> convertor = [AYDbKit convertorForType:@(@encode(type))]; \
    type result; \
    [convertor getBuffer:&result fromObject:value]; \
    return result;

- (short)shortValueForKey:(NSString *)aKey{
    CONVERT_TYPE_AND_RETURN(short);
}

- (unsigned short)unsignedShortValueForKey:(NSString *)aKey{
    CONVERT_TYPE_AND_RETURN(unsigned short);
}

- (int)intValueForKey:(NSString *)aKey{
    CONVERT_TYPE_AND_RETURN(int);
}

- (unsigned int)unsignedIntValueForKey:(NSString *)aKey{
    CONVERT_TYPE_AND_RETURN(unsigned int);
}

- (long)longValueForKey:(NSString *)aKey{
    CONVERT_TYPE_AND_RETURN(long);
}

- (unsigned long)unsignedLongValueForKey:(NSString *)aKey{
    CONVERT_TYPE_AND_RETURN(unsigned long);
}

- (long long)longLongValueForKey:(NSString *)aKey{
    CONVERT_TYPE_AND_RETURN(long long);
}

- (unsigned long long)unsignedLongLongValueForKey:(NSString *)aKey{
    CONVERT_TYPE_AND_RETURN(unsigned long long);
}

- (float)floatValueForKey:(NSString *)aKey{
    CONVERT_TYPE_AND_RETURN(float);
}

- (double)doubleValueForKey:(NSString *)aKey{
    CONVERT_TYPE_AND_RETURN(double);
}

- (BOOL)boolValueForKey:(NSString *)aKey{
    CONVERT_TYPE_AND_RETURN(BOOL);
}

- (NSInteger)integerValueForKey:(NSString *)aKey{
    CONVERT_TYPE_AND_RETURN(NSInteger);
}

- (NSUInteger)unsignedIntegerValueForKey:(NSString *)aKey{
    CONVERT_TYPE_AND_RETURN(NSUInteger);
}
#undef CONVERT_TYPE_AND_RETURN

@end
