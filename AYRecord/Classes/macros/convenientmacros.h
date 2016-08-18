//
//  Macros for convenient
//
//  Created by Alan Yeh on 15/10/8.
//  Copyright © 2015年 Alan Yeh. All rights reserved.
//

#ifndef AY_AYRECORD_CONVENIENT_MACROS_H
#define AY_AYRECORD_CONVENIENT_MACROS_H

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

#endif