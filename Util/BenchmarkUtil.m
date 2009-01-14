//
//  BenchmarkUtil.m
//  TapMania
//
//  Created by Alex Kremer on 29.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "BenchmarkUtil.h"
#import "TimingUtil.h"
#import <syslog.h>

@implementation BenchmarkUtil

+ (id) instanceWithName:(NSString*)lName {
	BenchmarkUtil* bm = [[BenchmarkUtil alloc] initWithName:lName];
	[bm start];
	return [bm autorelease];
}

- (id) initWithName:(NSString*)lName {
	self = [super init];
	if(!self)
		return nil;

	name = lName;

	startTime = 0.0f;
	finishTime = 0.0f;

	return self;
}

- (void) start {
	startTime = [TimingUtil getCurrentTime];
}

- (void) finish {
	finishTime = [TimingUtil getCurrentTime];
	[self stats];
}

- (void) stats {
	float delta = finishTime==0.0f ? [TimingUtil getCurrentTime] : finishTime - startTime;
	syslog(LOG_DEBUG, "Benchmark [%s] elapsed time: %lf", [name UTF8String], delta);
	NSLog(@"Benchmark [%s] elapsed time: %lf", [name UTF8String], delta);
}

@end
