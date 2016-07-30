//
//  AYTable.h
//  AYRecord
//
//  Created by Alan Yeh on 15/9/28.
//  Copyright © 2015年 Alan Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AYModel.h"

@protocol AYSetProtocol;
@class AYTable;
@class AYColumn;

/**
 *  table structure
 */
@interface AYTable : AYModel<AYTable *>
+ (instancetype)buildTableWithModel:(Class)model;

@property (nonatomic, copy) NSString *name;
@property (nonatomic) Class type;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *columns;
@property (nonatomic, assign) NSInteger version;


@property (nonatomic, readonly) NSArray<AYColumn *> *cols;

- (BOOL)hasColumn:(NSString *)column;
- (AYColumn *)columnForName:(NSString *)name;
@end
