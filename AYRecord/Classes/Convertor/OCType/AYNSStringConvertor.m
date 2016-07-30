//
//  AYNSStringConvertor.m
//  AYRecord
//
//  Created by Alan Yeh on 16/1/1.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import "AYNSStringConvertor.h"
#import "AYRecord_private.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface AYNSStringConvertor()
@property(nonatomic, retain) NSString *signature;
@end

@implementation AYNSStringConvertor
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
    return NSString.class;
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

- (void)bindObject:(NSString *)obj toColumn:(int)idx inStatement:(sqlite3_stmt *)statement{
    sqlite3_bind_text(statement, idx, [obj UTF8String], -1, SQLITE_STATIC);
}

- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    AYAssert([obj isKindOfClass:[NSString class]], @"can not conver <%@ %p> to NSString", [obj class], obj);
    memcpy(buffer, (void *)&obj, sizeof(id));
    return nil;
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    __unsafe_unretained id obj = nil;
    memcpy(&obj, buffer, sizeof(id));
    
    returnValIf(obj == nil, nil);
    AYAssert([obj isKindOfClass:[NSString class]], @"can not conver <%@ %p> to NSString", [obj class], obj);
    return obj;
}
@end
