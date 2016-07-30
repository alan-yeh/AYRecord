//
//  AYUnsignedCharConvertor.m
//  AYRecord
//
//  Created by Alan Yeh on 16/1/1.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import "AYUnsignedCharConvertor.h"
#import "AYRecord_private.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface AYUnsignedCharConvertor()
@property(nonatomic, assign) unsigned char signature;
@end

@implementation AYUnsignedCharConvertor
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
    sqlite3_bind_int(statement, idx, [obj unsignedCharValue]);
}

- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    AYAssert([obj isKindOfClass:[NSNumber class]], @"can not conver <%@ %p> to unsigned char", [obj class], obj);
    unsigned char value = [obj unsignedCharValue];
    memcpy(buffer, &value, sizeof(unsigned char));
    return strcmp([obj objCType], @encode(unsigned char)) == 0 ? nil : [NSNumber numberWithUnsignedChar:value];
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    unsigned char value;
    memcpy(&value, buffer, sizeof(unsigned char));
    return [NSNumber numberWithUnsignedChar:value];
}
@end
