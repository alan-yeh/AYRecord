//
//  AYCGRectConvertor.m
//  AYRecord
//
//  Created by Alan Yeh on 16/1/3.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import "AYCGRectConvertor.h"
#import "AYRecord_private.h"
#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import <objc/runtime.h>

@interface AYCGRectConvertor()
@property(nonatomic, assign) CGRect signature;
@end

@implementation AYCGRectConvertor
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
    if ([value isKindOfClass:[NSValue class]] && strcmp(@encode(CGRect), [value objCType]) == 0) {
        CGRect structValue = [value CGRectValue];
        memcpy(buffer, &structValue, sizeof(CGRect));
        return [obj isKindOfClass:NSData.class] ? value : nil;
    }
    
    AYAssert(NO, @"can not conver <%@ %p>:%@ to CGRect", [obj class], obj, obj);
    return nil;
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    CGRect value;
    memcpy(&value, buffer, sizeof(CGRect));
    return [NSValue valueWithCGRect:value];
}
@end
