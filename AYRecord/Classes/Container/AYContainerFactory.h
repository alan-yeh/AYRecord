//
//  AYContainerFactory.h
//  AYRecord
//
//  Created by Alan Yeh on 15/10/24.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AYSetProtocol;
@protocol AYDictionaryProtocol;

@protocol AYContainerFactory <NSObject>
- (nonnull id<AYSetProtocol>)createSet;
- (nonnull id<AYDictionaryProtocol>)createDictionary;
@end
