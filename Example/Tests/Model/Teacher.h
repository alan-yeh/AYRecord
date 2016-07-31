//
//  Teacher.h
//  UnitCase
//
//  Created by Alan Yeh on 15/10/10.
//  Copyright © 2015年 Alan Yeh. All rights reserved.
//

#import <AYRecord/AYRecord.h>

@class Teacher;
@interface Teacher : AYDbModel<Teacher *>
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) int age;


@property (nonatomic, assign) NSInteger floors;
@end
