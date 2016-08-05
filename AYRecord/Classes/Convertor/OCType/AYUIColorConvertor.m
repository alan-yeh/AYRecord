//
//  AYUIColorConvertor.m
//  AYRecord
//
//  Created by Alan Yeh on 16/1/11.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AYUIColorConvertor.h"
#import "AYRecord_private.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface AYUIColorConvertor()
@property(nonatomic, retain) UIColor *signature;
@end

@implementation AYUIColorConvertor
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
    return UIColor.class;
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
    sqlite3_bind_int64(statement, idx, [self ay_hexValueForColor:obj]);
}

- (id)getBuffer:(void *)buffer fromObject:(id)obj{
    returnValIf(obj == nil || [obj isEqual:[NSNull null]], nil);
    if ([obj isKindOfClass:[NSNumber class]]){
        int64_t value = (int64_t)[obj longLongValue];
        UIColor *color = [self ay_colorWithHex:value];
        memcpy(buffer, (void *)&color, sizeof(id));
        return color;
    }else if ([obj isKindOfClass:[UIColor class]]){
        memcpy(buffer, (void *)&obj, sizeof(id));
        return nil;
    }
    AYAssert(NO, @"can not conver <%@ %p>:%@ to UIColor", [obj class], obj, obj);
    return nil;
}

- (id)objectForBuffer:(void *)buffer{
    returnValIf(buffer == NULL, nil);
    __unsafe_unretained id obj = nil;
    memcpy(&obj, buffer, sizeof(id));
    
    returnValIf(obj == nil, nil);
    if ([obj isKindOfClass:[NSNumber class]]) {
        int64_t value = (int64_t)[obj longLongValue];
        return [self ay_colorWithHex:value];
    }else if ([obj isKindOfClass:[UIColor class]]){
        return obj;
    }
    AYAssert(NO, @"can not conver <%@ %p>:%@ to UIColor", [obj class]);
    return obj;
}

- (int64_t)ay_hexValueForColor:(UIColor *)color{
    CGFloat red, green, blue, alpha;
    [self ay_getRed:&red green:&green blue:&blue alpha:&alpha from:color];
    
    int64_t iRed, iGreen, iBlue, iAlpha;
    iAlpha = (int64_t)(alpha * 255);
    iRed = (int64_t)(red * 255);
    iGreen = (int64_t)(green * 255);
    iBlue = (int64_t)(blue * 255);
    
    int64_t result = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue;
    return result;
}

- (void)ay_getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha from:(UIColor *)color{
    CGColorRef colorRef = [color CGColor];
    const CGFloat *components = CGColorGetComponents(colorRef);
    
    size_t count = CGColorGetNumberOfComponents(colorRef);
    if (count == 4) {
        *red = components[0];
        *green = components[1];
        *blue = components[2];
        *alpha = components[3];
    }else if (count == 2){
        *red = components[0];
        *green = components[0];
        *blue = components[0];
        *alpha = components[1];
    }else{
        *red = 0;
        *green = 0;
        *blue = 0;
        *alpha = 0;
    }
}

- (UIColor *)ay_colorWithHex:(int64_t)hexValue{
    return [UIColor colorWithRed:((hexValue & 0xFF0000) >> 16)/255.0f
                           green:((hexValue & 0xFF00) >> 8)/255.0f
                            blue:(hexValue & 0xFF)/255.0f
                           alpha:((hexValue & 0xFF000000) >> 24)/255.0f];
}


@end
