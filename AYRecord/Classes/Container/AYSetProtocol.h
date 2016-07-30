//
//  AYSetProtocol.h
//  AYRecord
//
//  Created by Alan Yeh on 15/10/24.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AYSetProtocol <NSObject, NSFastEnumeration>
- (NSUInteger)count;

- (nonnull NSSet<id> *)toSet;

- (void)addValue:(nonnull id)value;
- (void)addValuesFormSet:(nonnull NSSet<id> *)set;
- (void)addValuesFormArray:(nonnull NSArray<id> *)array;
- (void)removeValue:(nonnull id)value;
- (void)removeAllValues;

- (BOOL)contains:(nonnull id)value;

- (BOOL)isEqual:(nonnull id<AYSetProtocol>)object;
@end
