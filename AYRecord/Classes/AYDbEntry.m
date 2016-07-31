//
//  AYDbEntry.m
//  AYRecord
//
//  Created by Alan Yeh on 15/10/10.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import "AYRecord_private.h"

@implementation AYDbEntry
- (id)copyWithZone:(NSZone *)zone{
    AYDbEntry *new = [[self.class allocWithZone:zone] initWithAttributes:self.attributes];
    return new;
}

+ (instancetype)entryWithAttributes:(NSDictionary<NSString *,id> *)attributes{
    return [[self alloc] initWithAttributes:attributes];
}

- (void)setEntry:(AYDbEntry *)anEntry{
    [self setDictionary:anEntry.attributes];
}

@end
