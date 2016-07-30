//
//  AYNSDataConvertor.m
//  AYRecord
//
//  Created by Alan Yeh on 16/1/1.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import "AYNSDataConvertor.h"
#import "AYRecord_private.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface AYNSDataConvertor()
@property(nonatomic, retain) NSData *signature;
@end

@implementation AYNSDataConvertor
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
    return NSData.class;
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

- (void)bindObject:(NSData *)obj toColumn:(int)idx inStatement:(sqlite3_stmt *)statement{
    sqlite3_bind_blob(statement, idx, [obj bytes], (int)[obj length], SQLITE_STATIC);
}

- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    AYAssert([obj isKindOfClass:[NSData class]], @"can not conver <%@ %p> to NSData", [obj class], obj);
    doIf(obj, memcpy(buffer, (void *)&obj, sizeof(id)));
    return nil;
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    __unsafe_unretained id obj = nil;
    memcpy(&obj, buffer, sizeof(id));
    
    returnValIf(obj == nil, nil);
    AYAssert([obj isKindOfClass:[NSData class]], @"can not conver <%@ %p> to NSData", [obj class], obj);
    return obj;
}
@end
