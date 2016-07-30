//
//  AYClassConvertor.m
//  AYRecord
//
//  Created by Alan Yeh on 16/1/2.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import "AYClassConvertor.h"
#import "AYRecord_private.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface AYClassConvertor()
@property(nonatomic, retain) Class signature;
@end

@implementation AYClassConvertor
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

- (void)bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt *)statement{
    sqlite3_bind_text(statement, idx, class_getName(obj), -1, SQLITE_STATIC);
}

- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    Class metaclass = object_getClass(obj);
    if (class_isMetaClass(metaclass)) {
        memcpy(buffer, (void *)&obj, sizeof(Class));
        return nil;
    }else if ([obj isKindOfClass:[NSString class]]){
        Class value = NSClassFromString(obj);
        if (value) {
            memcpy(buffer, (void *)&value, sizeof(Class));
            return value;
        }
    }
    
    AYAssert(NO, @"can not conver <%@ %p>:%@ to Class", [obj class], obj, obj);
    return nil;
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    __unsafe_unretained id obj = nil;
    memcpy(&obj, buffer, sizeof(Class));
    
    returnValIf(obj == nil, nil);
    if (class_isMetaClass(object_getClass(obj))) {
        return obj;
    }else if ([obj isKindOfClass:[NSString class]]){
        return NSClassFromString(obj);
    }
    
    AYAssert(NO, @"can not conver <%@ %p> to Class", [obj class], obj);
    return obj;
}

@end
