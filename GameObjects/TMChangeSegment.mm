//
//  $Id$
//  TMChangeSegment.m
//  TapMania
//
//  Created by Alex Kremer on 13.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMChangeSegment.h"


@implementation TMChangeSegment

@synthesize m_fNoteRow, m_fChangeValue; 

- (id) initWithNoteRow:(long) noteRow andValue:(float) value {
	self = [super init];
	if(!self)
		return nil;
	
	m_fNoteRow = noteRow;
	m_fChangeValue = value;

	return self;
}

// Serialization
- (id) initWithCoder: (NSCoder *) coder {
	self = [super init];
	
	m_fNoteRow = [coder decodeFloatForKey:@"r"];
	m_fChangeValue = [coder decodeFloatForKey:@"v"];
	
	return self;
}

- (void) encodeWithCoder: (NSCoder *) coder {
	[coder encodeFloat:m_fNoteRow forKey:@"r"];
	[coder encodeFloat:m_fChangeValue forKey:@"v"];
}

@end
