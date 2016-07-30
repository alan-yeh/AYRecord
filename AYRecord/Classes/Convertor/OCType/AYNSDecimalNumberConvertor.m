//
//  AYNSDecimalNumberConvertor.m
//  AYRecord
//
//  Created by Alan Yeh on 16/1/5.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import "AYNSDecimalNumberConvertor.h"
#import "AYRecord_private.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface AYNSDecimalNumberConvertor()
@property(nonatomic, retain) NSDecimalNumber *signature;
@end

@implementation AYNSDecimalNumberConvertor
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
    return NSDecimalNumber.class;
}

- (NSString *)dataType{
    return AYSQLiteTypeTEXT;
}

- (NSMethodSignature *)setterSignature{
    return [self methodSignatureForSelector:@selector(setSignature:)];
}

- (NSMethodSignature *)getterSignature{
    return [self methodSignatureForSelector:@selector(signature)];
}

- (void)bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt *)statement{
    NSString *value = [obj stringValue];
    sqlite3_bind_text(statement, idx, [value UTF8String], -1, SQLITE_STATIC);
}

- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    if ([obj isKindOfClass:[NSString class]]) {
        NSDecimalNumber *value = [NSDecimalNumber decimalNumberWithString:obj];
        memcpy(buffer, (void *)&value, sizeof(id));
        return value;
    }else if ([obj isKindOfClass:[NSDecimalNumber class]]){
        memcpy(buffer, (void *)&obj, sizeof(id));
        return nil;
    }
    AYAssert(NO, @"can not conver <%@ %p> to NSDecimalNumber", [obj class], obj);
    return nil;
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    __unsafe_unretained id obj = nil;
    memcpy(&obj, buffer, sizeof(id));
    
    returnValIf(obj == nil, nil);
    if ([obj isKindOfClass:[NSString class]]) {
        return [NSDecimalNumber decimalNumberWithString:obj];
    }else if ([obj isKindOfClass:[NSDecimalNumber class]]){
        return obj;
    }
    AYAssert(NO, @"can not conver <%@ %p> to NSDecimalNumber", [obj class], obj);
    return obj;
}
@end
