//
//  AYColumn.h
//  AYRecord
//
//  Created by Alan Yeh on 16/1/1.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AYModel.h"

@class AYColumn;
@protocol AYTypeConvertor;
/**
 *  column structure
 */
@interface AYColumn : NSObject
- (instancetype)initWithAttributes:(NSDictionary<NSString *, NSString *> *)attributes;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, weak, readonly) id<AYTypeConvertor> convertor;

@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *attributes;
@end
