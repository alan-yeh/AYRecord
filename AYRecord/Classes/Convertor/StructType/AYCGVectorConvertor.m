//
//  AYCGVectorConvertor.m
//  AYRecord
//
//  Created by Alan Yeh on 16/1/12.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import "AYCGVectorConvertor.h"
#import "AYRecord_private.h"
#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import <objc/runtime.h>

@interface AYCGVectorConvertor()
@property(nonatomic, assign) CGVector signature;
@end

@implementation AYCGVectorConvertor
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
    return NSValue.class;
}

- (NSString *)dataType{
    return AYSQLiteTypeBLOG;
}

- (NSMethodSignature *)setterSignature{
    return [self methodSignatureForSelector:@selector(setSignature:)];
}

- (NSMethodSignature *)getterSignature{
    return [self methodSignatureForSelector:@selector(signature)];
}

- (void)bindObject:(NSValue *)obj toColumn:(int)idx inStatement:(sqlite3_stmt *)statement{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    sqlite3_bind_blob(statement, idx, [data bytes], (int)[data length], NULL);
}

- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    NSValue *value = obj;
    if ([value isKindOfClass:[NSData class]]) {
        value = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
    }
    if ([value isKindOfClass:[NSValue class]] && strcmp(@encode(CGVector), [value objCType]) == 0) {
        CGVector structValue = [value CGVectorValue];
        memcpy(buffer, &structValue, sizeof(CGVector));
        return [obj isKindOfClass:NSData.class] ? value : nil;
    }
    
    AYAssert(NO, @"can not conver <%@ %p>:%@ to CGVector", [obj class], obj, obj);
    return nil;
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    CGVector value;
    memcpy(&value, buffer, sizeof(CGVector));
    return [NSValue valueWithCGVector:value];
}
@end
