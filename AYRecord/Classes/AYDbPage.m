//
//  AYDbPage.m
//  AYRecord
//
//  Created by Alan Yeh on 15/9/29.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import "AYRecord_private.h"

@implementation AYDbPage

+ (instancetype)pageWithArray:(NSArray *)list index:(NSInteger)pageIndex size:(NSInteger)pageSize total:(NSInteger)totalRow{
    return [[self alloc] initWithArray:list index:pageIndex size:pageSize total:totalRow];
}

- (instancetype)initWithArray:(NSArray *)list index:(NSInteger)pageIndex size:(NSInteger)pageSize total:(NSInteger)totalRow{
    if (self = [super init]) {
        _list = [list copy];
        _pageIndex = pageIndex;
        _pageSize = pageSize;
        _totalRow = totalRow;
        if (totalRow == 0 || pageSize == 0) {
            _totalRow = 0;
        }else{
            _totalPage = (totalRow / pageSize);
            if (totalRow % pageSize != 0) {
                _totalPage ++;
            }
        }
    }
    return self;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"<AYDbPage %p>:\n{\n   page index : %@,\n   page size : %@,\n   total page : %@,\n   total row : %@,\n   list: %@\n}", self, @(self.pageIndex), @(self.pageSize), @(self.totalPage), @(self.totalRow), self.list];
}
@end
