//
//  AYShortConvertor.m
//  AYRecord
//
//  Created by Alan Yeh on 16/1/1.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import "AYShortConvertor.h"
#import "AYRecord_private.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface AYShortConvertor()
@property(nonatomic, assign) short signature;
@end

@implementation AYShortConvertor
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
    sqlite3_bind_int(statement, idx, [obj shortValue]);
}

- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    if ([obj isKindOfClass:[NSString class]]) {
        int ivalue = [obj intValue];
        short value = (short)ivalue;
        memcpy(buffer, &value, sizeof(short));
        return [NSNumber numberWithShort:value];
    }else if ([obj isKindOfClass:[NSNumber class]]){
        short value = [obj shortValue];
        memcpy(buffer, &value, sizeof(short));
        return strcmp([obj objCType], @encode(short)) == 0 ? nil : [NSNumber numberWithShort:value];
    }
    AYAssert(NO, @"can not conver <%@ %p>:%@ to short", [obj class], obj, obj);
    return nil;
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    short value;
    memcpy(&value, buffer, sizeof(short));
    return [NSNumber numberWithShort:value];
}
@end
