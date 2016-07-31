//
//  AYDbTable.h
//  AYRecord
//
//  Created by Alan Yeh on 15/9/28.
//  Copyright © 2015年 Alan Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AYDbModel.h"

@protocol AYSetProtocol;
@class AYDbTable;
@class AYDbColumn;

/**
 *  table structure
 */
@interface AYDbTable : AYDbModel<AYDbTable *>
+ (instancetype)buildTableWithModel:(Class)model;

@property (nonatomic, copy) NSString *name;
@property (nonatomic) Class type;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *columns;
@property (nonatomic, assign) NSInteger version;


@property (nonatomic, readonly) NSArray<AYDbColumn *> *cols;

- (BOOL)hasColumn:(NSString *)column;
- (AYDbColumn *)columnForName:(NSString *)name;
@end
