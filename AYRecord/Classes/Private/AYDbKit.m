//
//  AYDbKit.m
//  AYRecord
//
//  Created by Alan Yeh on 15/10/1.
//  Copyright © 2015年 Alan Yeh. All rights reserved.
//

#import "AYRecord_private.h"
#import "metamacros.h"
#import "AYConvertors.h"
#import <objc/runtime.h>

@implementation AYDbKit
+ (AYDbConfig *)brokenConfig{
    static AYDbConfig *_broken_config;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _broken_config = [AYDbConfig new];
    });
    return _broken_config;
}

static AYDbConfig *mainConfig;
+ (AYDbConfig *)mainConfig{
    return mainConfig;
}

#pragma mark -
+ (NSMutableDictionary<NSString *, AYDbConfig *> *)nameToConfig{
    static NSMutableDictionary<NSString *, AYDbConfig *> *_nameToConfig = nil;
    return _nameToConfig ?: (_nameToConfig = [NSMutableDictionary new]);
}

+ (NSMutableDictionary<NSString *, AYDbConfig *> *)modelToConfig{
    static NSMutableDictionary<NSString *, AYDbConfig *> *_modelConfigMap = nil;
    return _modelConfigMap ?: (_modelConfigMap = [NSMutableDictionary new]);
}

+ (NSMutableDictionary<NSString *, AYTable *> *)nameToTable{
    static NSMutableDictionary<NSString *, AYTable *> *_nameTableMap = nil;
    return _nameTableMap ?: (_nameTableMap = [NSMutableDictionary new]);
}

+ (NSMutableDictionary<NSString *, AYTable *> *)modelToTable{
    static NSMutableDictionary<NSString *, AYTable *> *_modelTableMap = nil;
    return _modelTableMap ?: (_modelTableMap = [NSMutableDictionary new]);
}

+ (NSMutableSet<NSString *> *)datasources{
    static NSMutableSet<NSString *> *_datasources = nil;
    return _datasources ?: (_datasources = [NSMutableSet new]);
}

+ (void)addConfig:(AYDbConfig *)config{
    AYAssert(config, @"Config can not be null");
    AYAssert(![[self.nameToConfig allKeys]containsObject:config.name], @"Config already exists: ", config.name);
    AYAssert(![self.datasources containsObject:config.datasource], @"Datasource for %@ is already exists.", config.name);
    [self.datasources addObject:config.datasource];
    
    [self.nameToConfig setObject:config forKey:config.name.lowercaseString];
    
    if ([@"main" isEqualToString:config.name.lowercaseString]) {
        mainConfig = config;
    }
    
    if (!mainConfig) {
        mainConfig = config;
    }
}

+ (void)addModel:(Class)model toConfigMapping:(AYDbConfig *)config{
    [self.modelToConfig setObject:config forKey:NSStringFromClass(model)];
}

+ (void)addModel:(Class)model toTableMapping:(AYTable *)table{
    [self.modelToTable setObject:table forKey:NSStringFromClass(model)];
    [self.nameToTable setObject:table forKey:[table stringValueForKey:@"name"].lowercaseString];
}

+ (AYDbConfig *)configForName:(NSString *)configName{
    return [self.nameToConfig objectForKey:[configName lowercaseString]];
}

+ (AYDbConfig *)configForModel:(Class)model{
    return [self.modelToConfig objectForKey:NSStringFromClass(model)];
}

+ (AYTable *)tableForModel:(Class)model{
    return [self.modelToTable objectForKey:NSStringFromClass(model)];
}

+ (AYTable *)tableForName:(NSString *)tableName{
    return [self.nameToTable objectForKey:[tableName lowercaseString]];
}

#pragma mark -
+ (NSMutableSet<id<AYTypeConvertor>> *)convertors{
    static NSMutableSet<id<AYTypeConvertor>> *_convertors;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableSet<id<AYTypeConvertor>> *set = [NSMutableSet new];
        
#define CONVERTOR(Type) metamacro_concat(metamacro_concat(AY, Type), Convertor)
#define REGISTER_CONVERTOR(Type) \
    [set addObject:[CONVERTOR(Type) new]];
        
        //CType
        REGISTER_CONVERTOR(Char);
        REGISTER_CONVERTOR(UnsignedChar);
        REGISTER_CONVERTOR(Short);
        REGISTER_CONVERTOR(UnsignedShort);
        REGISTER_CONVERTOR(Int);
        REGISTER_CONVERTOR(UnsignedInt);
        REGISTER_CONVERTOR(Long);
        REGISTER_CONVERTOR(UnsignedLong);
        REGISTER_CONVERTOR(LongLong);//not used in 64bit
        REGISTER_CONVERTOR(UnsignedLongLong);//not used in 64bit
        REGISTER_CONVERTOR(Float);
        REGISTER_CONVERTOR(Double);
        REGISTER_CONVERTOR(Bool);
        
        //OCType
        REGISTER_CONVERTOR(Class);
        REGISTER_CONVERTOR(NSData);
        REGISTER_CONVERTOR(NSDate);
        REGISTER_CONVERTOR(NSDecimalNumber);
        REGISTER_CONVERTOR(NSString);
        REGISTER_CONVERTOR(NSURL);
        REGISTER_CONVERTOR(NSValue);
        REGISTER_CONVERTOR(UIColor);
        
        //StructType
        REGISTER_CONVERTOR(CGAffineTransform);
        REGISTER_CONVERTOR(CGPoint);
        REGISTER_CONVERTOR(CGRect);
        REGISTER_CONVERTOR(CGSize);
        REGISTER_CONVERTOR(CGVector);
        REGISTER_CONVERTOR(UIEdgeInsets);
        REGISTER_CONVERTOR(UIOffset);
        REGISTER_CONVERTOR(NSRange);
        
#undef REGISTER_CONVERTOR
#undef CONVERTOR
        _convertors = set;
    });
    return _convertors;
}

+ (NSMapTable<NSString *, id<AYTypeConvertor>> *)typeConvertors{
    static NSMapTable<NSString *, id<AYTypeConvertor>> *_encode_convertor_map;
    return _encode_convertor_map ?: (_encode_convertor_map = ({
        NSMapTable<NSString *, id<AYTypeConvertor>> *map = [NSMapTable strongToWeakObjectsMapTable];
        for (id<AYTypeConvertor> convertor in self.convertors) {
            [map setObject:convertor forKey:convertor.type];
        }
        map;
    }));
}

+ (id<AYTypeConvertor>)convertorForType:(NSString *)typeEncoding{
    id<AYTypeConvertor> convertor = [self.typeConvertors objectForKey:typeEncoding];
    AYAssert(convertor, @"can not find suitable convertor for type: %@", typeEncoding);
    return convertor;
}

+ (id<AYTypeConvertor>)convertorForObject:(id)obj{
    static NSMapTable<NSString *, id<AYTypeConvertor>> *numberConvertorMap = nil;
    static NSMapTable<NSString *, id<AYTypeConvertor>> *valueConvertorMap = nil;
    static NSMapTable<NSString *, id<AYTypeConvertor>> *otherConvertorMap = nil;
    static __weak AYClassConvertor *classConvertor;//AYClassConvertor
    static NSMutableSet<Class> *otherTypes = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        numberConvertorMap = [NSMapTable strongToWeakObjectsMapTable];
        valueConvertorMap = [NSMapTable strongToWeakObjectsMapTable];
        otherConvertorMap = [NSMapTable strongToWeakObjectsMapTable];
        otherTypes = [NSMutableSet new];
        
        [self.convertors enumerateObjectsUsingBlock:^(id<AYTypeConvertor>  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj.objcType isSubclassOfClass:NSNumber.class]) {
                [numberConvertorMap setObject:obj forKey:obj.type];
            }else if ([obj.objcType isSubclassOfClass:NSValue.class]){
                [valueConvertorMap setObject:obj forKey:obj.type];
            }else{
                if (![obj isKindOfClass:[AYClassConvertor class]]) {
                    [otherConvertorMap setObject:obj forKey:NSStringFromClass(obj.objcType)];
                    [otherTypes addObject:obj.objcType];
                }else{
                    classConvertor = obj;
                }
            }
            
        }];
    });
    
    returnValIf(!obj, nil);
    
    id<AYTypeConvertor> convertor = nil;
    Class class = object_getClass(obj);
    
    if (class_isMetaClass(class)) {
        convertor = classConvertor;
    }else if ([class isSubclassOfClass:NSNumber.class]){
        NSString *key = [NSString stringWithUTF8String:[obj objCType]];
        convertor = [numberConvertorMap objectForKey:key];
    }else if ([class isSubclassOfClass:NSValue.class]){
        NSString *key = [NSString stringWithUTF8String:[obj objCType]];
        convertor = [valueConvertorMap objectForKey:key];
    }
    if (convertor == nil) {
        for (Class type in otherTypes) {
            if ([class isSubclassOfClass:type]) {
                convertor = [otherConvertorMap objectForKey:NSStringFromClass(type)];
                break;
            }
        }
    }
    
    AYAssert(convertor, @"can not find suitable convertor for obj:<%@ %p>", NSStringFromClass([obj class]), obj);
    return convertor;
}

+ (void)addConvertor:(id<AYTypeConvertor>)convertor{
    [self.convertors addObject:convertor];
}

@end
