//
//  AYUnsignedLongConvertor.m
//  AYRecord
//
//  Created by Alan Yeh on 16/1/1.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import "AYUnsignedLongConvertor.h"
#import "AYRecord_private.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface AYUnsignedLongConvertor()
@property(nonatomic, assign) unsigned long signature;
@end

@implementation AYUnsignedLongConvertor
- (NSString *)type{
    static NSString *_type = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_property_t property = class_getProperty(self.class, "signature");
        char *type = property_copyAttributeValue(property, "T");
        _type = @(type);
        free((void *)type);
    });
    return _type;
}

- (Class)objcType{
    return NSNumber.class;
}

- (NSString *)dataType{
    return AYSQLiteTypeINTEGER;
}

- (NSMethodSignature *)setterSignature{
    return [self methodSignatureForSelector:@selector(setSignature:)];
}

- (NSMethodSignature *)getterSignature{
    return [self methodSignatureForSelector:@selector(signature)];
}

- (void)bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt *)statement{
    sqlite3_bind_int64(statement, idx, [obj unsignedLongValue]);
}

- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    if ([obj isKindOfClass:[NSString class]]) {
        long long llvalue = [obj longLongValue];
        unsigned long value = (unsigned long)llvalue;
        memcpy(buffer, &value, sizeof(unsigned long));
        return [NSNumber numberWithUnsignedLong:value];
    }else if ([obj isKindOfClass:[NSNumber class]]){
        unsigned long value = [obj unsignedLongValue];
        memcpy(buffer, &value, sizeof(unsigned long));
        return strcmp([obj objCType], @encode(unsigned long)) == 0 ? nil : [NSNumber numberWithUnsignedLong:value];
    }
    AYAssert(NO, @"can not conver <%@ %p>:%@ to unsigned long", [obj class], obj, obj);
    return nil;
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    unsigned long value;
    memcpy(&value, buffer, sizeof(unsigned long));
    return [NSNumber numberWithUnsignedLong:value];
}
@end
