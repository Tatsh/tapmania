//
//  TMChangeSegment.m
//  TapMania
//
//  Created by Alex Kremer on 13.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMChangeSegment.h"


@implementation TMChangeSegment

@synthesize noteRow, changeValue; 

- (id) initWithNoteRow:(int) lNoteRow andValue:(float) lValue {
	self = [super init];
	if(!self)
		return nil;
	
	noteRow = lNoteRow;
	changeValue = lValue;

	return self;
}

@end
