//
//  AYDbEntry.h
//  AYRecord
//
//  Created by Alan Yeh on 15/10/10.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AYRecord/AYDbAttribute.h>

NS_ASSUME_NONNULL_BEGIN
@interface AYDbEntry : AYDbAttribute
+ (instancetype)entryWithAttributes:(NSDictionary<NSString *, id> *)attributes;

- (void)setEntry:(AYDbEntry *)anEntry;/**< Copy attribute from ${anEntry} to entry. */
@end
NS_ASSUME_NONNULL_END