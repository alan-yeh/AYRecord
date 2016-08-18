//
//  Macros for AYRecord
//
//  Created by Alan Yeh on 15/10/8.
//  Copyright © 2015年 Alan Yeh. All rights reserved.
//

#ifndef AY_AYRECORD_MACROS_H
#define AY_AYRECORD_MACROS_H

#define returnValIf(condition, val) if (!!(condition)){ return val;}
#define returnIf(condition)         if (!!(condition)){ return;    }
#define breakIf(condition)          if (!!(condition)){ break;     }
#define continueIf(condition)       if (!!(condition)){ continue;  }

#define doIf(condition, action) \
   do {                         \
      if(!!(condition)){        \
         action;                \
      }                         \
   } while(0)

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

#endif