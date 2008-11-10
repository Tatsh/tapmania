//
//  TimingUtil.m
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TimingUtil.h"

#include <mach/mach.h>
#include <mach/mach_time.h>

@implementation TimingUtil

+ (double) getCurrentTime {
	static mach_timebase_info_data_t sTimebaseInfo;
	uint64_t time = mach_absolute_time();
	uint64_t nanos;
	
	if( sTimebaseInfo.denom == 0 ) {
		(void) mach_timebase_info(&sTimebaseInfo);
	}
	
	nanos = time * sTimebaseInfo.numer / sTimebaseInfo.denom;
	return ((double)nanos / 1000000000.0);
}

@end
