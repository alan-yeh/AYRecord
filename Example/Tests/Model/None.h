//
//  None.h
//  AYRecord
//
//  Created by Alan Yeh on 16/3/3.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import <AYRecord/AYRecord.h>

@class None;

@interface None : AYModel<None *>
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) int age;
@end
