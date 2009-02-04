//
//  TMChangeSegment.m
//  TapMania
//
//  Created by Alex Kremer on 13.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMChangeSegment.h"


@implementation TMChangeSegment

@synthesize m_fNoteRow, m_fChangeValue; 

- (id) initWithNoteRow:(int) noteRow andValue:(float) value {
	self = [super init];
	if(!self)
		return nil;
	
	m_fNoteRow = noteRow;
	m_fChangeValue = value;

	return self;
}

@end
