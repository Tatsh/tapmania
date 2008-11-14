//
//  TMBeatBasedChange.m
//  TapMania
//
//  Created by Alex Kremer on 13.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMBeatBasedChange.h"


@implementation TMBeatBasedChange

@synthesize beat, changeValue; 

- (id) initWithBeat:(float) lBeat andValue:(float) lValue {
	self = [super init];
	if(!self)
		return nil;
	
	beat = lBeat;
	changeValue = lValue;

	return self;
}

@end
