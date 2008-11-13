//
//  TMTimeBasedChange.m
//  TapMania
//
//  Created by Alex Kremer on 13.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMTimeBasedChange.h"


@implementation TMTimeBasedChange

@synthesize time, changeValue; 

- (id) initWithTime:(double) lTime andValue:(double) lValue {
	self = [super init];
	if(!self)
		return nil;
	
	time = lTime;
	changeValue = lValue;

	return self;
}

@end
