//
//  AYDoubleConvertor.m
//  AYRecord
//
//  Created by Alan Yeh on 16/1/1.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import "AYDoubleConvertor.h"
#import "AYRecord_private.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface AYDoubleConvertor()
@property(nonatomic, assign) double signature;
@end

@implementation AYDoubleConvertor
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
    return AYSQLiteTypeREAL;
}

- (NSMethodSignature *)setterSignature{
    return [self methodSignatureForSelector:@selector(setSignature:)];
}

- (NSMethodSignature *)getterSignature{
    return [self methodSignatureForSelector:@selector(signature)];
}

- (void)bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt *)statement{
    sqlite3_bind_double(statement, idx, [obj doubleValue]);
}

- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    if ([obj isKindOfClass:[NSString class]]) {
        double value = [obj doubleValue];
        memcpy(buffer, &value, sizeof(double));
        return [NSNumber numberWithDouble:value];
    }else if ([obj isKindOfClass:[NSNumber class]]){
        double value = [obj doubleValue];
        memcpy(buffer, &value, sizeof(double));
        return strcmp([obj objCType], @encode(double)) == 0 ? nil : [NSNumber numberWithDouble:value];
    }
    AYAssert(NO, @"can not conver <%@ %p>:%@ to double", [obj class], obj, obj);
    return nil;
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    double value;
    memcpy(&value, buffer, sizeof(double));
    return [NSNumber numberWithDouble:value];
}
@end
