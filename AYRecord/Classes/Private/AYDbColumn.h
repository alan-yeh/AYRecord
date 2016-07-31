//
//  AYDbColumn.h
//  AYRecord
//
//  Created by Alan Yeh on 16/1/1.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AYDbModel.h"

@class AYDbColumn;
@protocol AYDbTypeConvertor;
/**
 *  column structure
 */
@interface AYDbColumn : NSObject
- (instancetype)initWithAttributes:(NSDictionary<NSString *, NSString *> *)attributes;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, weak, readonly) id<AYDbTypeConvertor> convertor;

@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *attributes;
@end
