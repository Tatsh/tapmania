//
//  TMNote.m
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMNote.h"


@implementation TMNote

- (id) initWithTime:(double) lTime {
	self = [super init];
	if(!self)
		return nil;
	
	time = lTime;
	tillTime = lTime; // FIXME
	beatType = 0; // FIXME
	
	return self;
}

@end
