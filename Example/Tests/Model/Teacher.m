//
//  Teacher.m
//  UnitCase
//
//  Created by Alan Yeh on 15/10/10.
//  Copyright © 2015年 Alan Yeh. All rights reserved.
//

#import "Teacher.h"
#import "Student.h"

@implementation Teacher
@dynamic name;
@dynamic age;

- (NSArray<Student *> *)getStudents{
    return nil;
//    return [[Student dao] find:@"select * from student where teacher_id = ?", [self valueForKey:@"id"]];
}

@end
