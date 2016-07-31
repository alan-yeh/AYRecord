//
//  Student.h
//  UnitCase
//
//  Created by Alan Yeh on 15/10/8.
//  Copyright © 2015年 Alan Yeh. All rights reserved.
//

#import <AYRecord/AYRecord.h>

@class Student;

@interface Student : AYDbModel<Student *>
@property (nonatomic, retain) NSString *name;/**< 姓名 */
@property (nonatomic, assign) int age;/**< 年龄 */
@property (nonatomic, retain) NSDate *date;
@end
