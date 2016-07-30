//
//  AYIntConvertor.m
//  AYRecord
//
//  Created by Alan Yeh on 16/1/1.
//  Copyright © 2016年 yerl. All rights reserved.
//

#import "AYIntConvertor.h"
#import "AYRecord_private.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface AYIntConvertor()
@property(nonatomic, assign) int signature;
@end

@implementation AYIntConvertor
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
    sqlite3_bind_int(statement, idx, [obj intValue]);
}

- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    if ([obj isKindOfClass:[NSString class]]) {
        int value = [obj intValue];
        memcpy(buffer, &value, sizeof(int));
        return [NSNumber numberWithInt:value];
    }else if ([obj isKindOfClass:[NSNumber class]]){
        int value = [obj intValue];
        memcpy(buffer, &value, sizeof(int));
        return strcmp([obj objCType], @encode(int)) == 0 ? nil : [NSNumber numberWithInt:value];
    }
    AYAssert(NO, @"can not conver <%@ %p>:%@ to int", [obj class], obj, obj);
    return nil;
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    int value;
    memcpy(&value, buffer, sizeof(int));
    return [NSNumber numberWithInt:value];
}
@end
