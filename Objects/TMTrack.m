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

- (void) setNote:(TMNote*) note onNoteRow:(int)noteRow {
	
	int i = 0;
	for(; i<[notesArray count]; i++){
		if( [(TMNote*)[ notesArray objectAtIndex:i] startNoteRow] == noteRow ) {
			[notesArray replaceObjectAtIndex:i withObject:note];		
			return;
		}
	}
	
	note.startNoteRow = noteRow;
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
