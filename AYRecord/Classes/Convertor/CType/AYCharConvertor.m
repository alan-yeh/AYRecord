//
//  AYCharConvertor.m
//  AYRecord
//
//  Created by Alan Yeh on 16/1/1.
//  Copyright © 2016年 yerl. All rights reserved.
//

#import "AYCharConvertor.h"
#import "AYRecord_private.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface AYCharConvertor ()
@property(nonatomic, assign) char signature;
@end

@implementation AYCharConvertor
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
    sqlite3_bind_int(statement, idx, [obj charValue]);
}

- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    AYAssert([obj isKindOfClass:[NSNumber class]], @"can not conver <%@ %p>:%@ to char", [obj class], obj, obj);
    char value = [obj charValue];
    memcpy(buffer, &value, sizeof(char));
    return strcmp([obj objCType], @encode(char)) == 0 ? nil : [NSNumber numberWithChar:value];
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    char value;
    memcpy(&value, buffer, sizeof(char));
    return [NSNumber numberWithChar:value];
}
@end
