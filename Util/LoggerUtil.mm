//
//  $Id$
//  LoggerUtil.c
//  TapMania
//
//  Created by Alex Kremer on 10.02.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "LoggerUtil.h"
#import <syslog.h>
#import <stdarg.h>

void tapMania_debug(NSString *format, ...)
{
    va_list lst;
    const char *fmt = [format UTF8String];

    va_start(lst, fmt);
    NSString *st = [[NSString alloc] initWithFormat:format arguments:lst];

    // Do both NSLog and syslog
#if defined(DEBUG_SIMULATOR) || SYSLOG_USED == 0
    NSLog(st);
#endif
#if defined(DEBUG_IPHONE) && SYSLOG_USED == 1
	syslog(LOG_DEBUG, [st UTF8String]);
#endif

    [st release];
}
