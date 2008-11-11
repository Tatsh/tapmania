//
//  TMTrack.m
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMTrack.h"


@implementation TMTrack

- (id) init {
	self = [super init];
	if (!self)
		return nil;
	
	// Alloc space for the notes array
	notesArray = [[NSMutableArray alloc] initWithCapacity:50];
	
	return self;
}

- (void) addNote:(TMNote*) note {
	[notesArray addObject:note];
}

- (TMNote*) getNote:(int) index {
	return [notesArray objectAtIndex:index];
}

- (int) getNotesCount {
	return [notesArray count];
}

- (void) dealloc {
	[notesArray release];
	[super dealloc];
}

@end
