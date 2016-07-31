//
//  AYDbPage.h
//  AYRecord
//
//  Created by Alan Yeh on 15/9/29.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * AYDbPage is the result of AYDbModel.paginate(......) or AYDb.paginate(......)
 */
@interface AYDbPage<M> : NSObject
@property (nonatomic, strong, nonnull, readonly) NSArray<M> *list;
@property (nonatomic, assign, readonly) NSInteger pageIndex;
@property (nonatomic, assign, readonly) NSInteger pageSize;
@property (nonatomic, assign, readonly) NSInteger totalPage;
@property (nonatomic, assign, readonly) NSInteger totalRow;

+ (nonnull instancetype)pageWithArray:(nonnull NSArray<M> *)list index:(NSInteger)pageIndex size:(NSInteger)pageSize total:(NSInteger)totalRow;
@end
