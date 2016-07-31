//
//  AYDbColumn.m
//  AYRecord
//
//  Created by Alan Yeh on 16/1/1.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import "AYRecord_private.h"

@implementation AYDbColumn{
    __weak id<AYDbTypeConvertor> _convertor;
}

- (instancetype)initWithAttributes:(NSDictionary<NSString *,NSString *> *)attributes{
    if (self = [super init]) {
        _name = attributes[@"name"];
        _type = attributes[@"type"];
    }
    return self;
}

- (BOOL)isEqual:(AYDbColumn *)object{
    returnValIf(![object isKindOfClass:self.class], NO);
    return [object.name isEqualToString:self.name] && [object.type isEqualToString:self.type];
}

- (NSUInteger)hash{
    return self.type.hash + self.name.hash;
}

- (id<AYDbTypeConvertor>)convertor{
    return _convertor ?: (_convertor = [AYDbKit convertorForType:self.type]);
}

- (NSDictionary<NSString *,NSString *> *)attributes{
    NSMutableDictionary<NSString *, NSString *> *attributes = [NSMutableDictionary dictionary];
    attributes[@"name"] = self.name;
    attributes[@"type"] = self.type;
    return attributes;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"<AYDbColumn %p> { name : %@, type : %@}", self, self.name, self.type];
}

- (NSString *)debugDescription{
    return [NSString stringWithFormat:@"<AYDbColumn %p>\n{\n   name : %@,\n   type : %@\n}", self, self.name, self.type];
}
@end
