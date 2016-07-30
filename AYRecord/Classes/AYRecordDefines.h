//
//  AYRecordDefines.h
//  AYRecord
//
//  Created by Alan Yeh on 16/2/19.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#ifndef AYRecordDefines_h
#define AYRecordDefines_h

#if defined(__cplusplus)
#define AYRecord_EXTERN extern "C"
#else
#define AYRecord_EXTERN extern
#endif

#define AYRecord_EXTERN_STRING(KEY, COMMENT) AYRecord_EXTERN NSString * const _Nonnull KEY;
#define AYRecord_EXTERN_STRING_IMP(KEY) NSString * const KEY = @#KEY;
#define AYRecord_EXTERN_STRING_IMP2(KEY, VAL) NSString * const KEY = VAL;

#define AYRecord_ENUM_OPTION(ENUM, VAL, COMMENT) ENUM = VAL

#define AYRecord_API_UNAVAILABLE(INFO) __attribute__((unavailable(INFO)))

#endif /* AYRecordDefines_h */
