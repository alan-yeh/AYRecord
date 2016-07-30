//
//  AYNSValueConvertor.m
//  AYRecord
//
//  Created by Alan Yeh on 16/1/5.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import "AYNSValueConvertor.h"
#import "AYRecord_private.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface AYNSValueConvertor()
@property(nonatomic, retain) NSValue *signature;
@end

@implementation AYNSValueConvertor
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

- (void)bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt *)statement{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    sqlite3_bind_blob(statement, idx, [data bytes], (int)[data length], NULL);
}

- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    AYAssert([obj isKindOfClass:[NSValue class]], @"can not conver <%@ %p> to NSValue", [obj class], obj);
    memcpy(buffer, (void *)&obj, sizeof(id));
    return nil;
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    __unsafe_unretained id obj = nil;
    memcpy(&obj, buffer, sizeof(id));
    
    returnValIf(obj == nil, nil);
    AYAssert([obj isKindOfClass:[NSValue class]], @"can not conver <%@ %p> to NSValue", [obj class], obj);
    return obj;
}
@end
