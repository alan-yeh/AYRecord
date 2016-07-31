//
//  AYRecord_private.h
//  AYRecord
//
//  Created by Alan Yeh on 15/10/19.
//  Copyright © 2015年 Alan Yeh. All rights reserved.
//

#define va_array(arg_start) ({ \
   NSMutableArray *params = [NSMutableArray new]; \
   NSUInteger count = [arg_start componentsSeparatedByString:@"?"].count - 1; \
   va_list va; va_start(va, arg_start); \
   for(NSInteger i = 0; i < count; i ++){ \
      id arg = va_arg(va, id); \
      breakIf(!arg); \
      doIf(arg, [params addObject:arg]); \
   } \
   va_end(va); \
   params; \
})

#define AYRecord_THREAD_TRANSACTION_CONFIG @"AYRecord_THREAD_TRANSACTION_CONFIG"

#import "AYRecordDefines.h"
#import "AYDbContext.h"
#import "AYDb.h"
#import "AYDbModel.h"
#import "AYDbEntry.h"
#import "AYDbPage.h"
#import "AYDbSql.h"
#import "AYDbAttribute.h"
#import "AYDictionaryProtocol.h"
#import "AYSetProtocol.h"
#import "AYCaseInsensitiveContainerFactory.h"
#import "AYCaseSensitiveContainerFactory.h"
#import "AYDbTypeConvertor.h"


#import "AYDbTable.h"
#import "AYDbColumn.h"
#import "AYDbSqlBuilder.h"
#import "AYDbConfig.h"
#import "AYDbConnection.h"
#import "AYDbKit.h"
#import "convenientmacros.h"
#import "objc.h"
#import "AYDbAssert.h"
