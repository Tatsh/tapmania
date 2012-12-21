//
//  $Id$
//  LoggerUtil.h
//
//  Created by Alex Kremer on 10.02.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#ifndef _DEBUG_UTIL_H_
#define _DEBUG_UTIL_H_

#import <UIKit/UIKit.h>

#if defined(TARGET_IPHONE_SIMULATOR) && TARGET_IPHONE_SIMULATOR == 1
#define DEBUG_SIMULATOR 1
#define SYSLOG_USED 0
#else
#define DEBUG_IPHONE 1
#define SYSLOG_USED 0
#endif

#ifdef DEBUG
#define TMLog(a...) tapMania_debug(a)
#else
#define TMLog(a...)
#endif

#ifdef __cplusplus
extern "C" {
#endif

void tapMania_debug(NSString *format, ...);

#ifdef __cplusplus
}
#endif

#endif