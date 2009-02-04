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
	m_aNotesArray = [[NSMutableArray alloc] initWithCapacity:50];
	
	return self;
}

- (void) setNote:(TMNote*) note onNoteRow:(int)noteRow {
	
	int i = 0;
	for(; i<[m_aNotesArray count]; ++i){
		if( [(TMNote*)[ m_aNotesArray objectAtIndex:i] m_nStartNoteRow] == noteRow ) {
			[m_aNotesArray replaceObjectAtIndex:i withObject:note];		
			return;
		}
	}
	
	note.m_nStartNoteRow = noteRow;
	[m_aNotesArray addObject:note];
}

- (TMNote*) getNoteFromRow:(int)noteRow {
	int i = 0;
	
	while(i < [m_aNotesArray count]) {
		if( [(TMNote*)[ m_aNotesArray objectAtIndex:i] m_nStartNoteRow] < noteRow ){
			++i;
			continue;
		}
	
		if( [(TMNote*)[ m_aNotesArray objectAtIndex:i] m_nStartNoteRow] == noteRow )
			return (TMNote*)[ m_aNotesArray objectAtIndex:i];
		else
			return nil;
	}
	
	return nil;
}

- (BOOL) hasNoteAtRow:(int)noteRow {
	int i = 0;
	
	while(i < [m_aNotesArray count]) {
		if( [(TMNote*)[ m_aNotesArray objectAtIndex:i] m_nStartNoteRow] < noteRow ) {
			++i;
			continue;
		}
		
		if( [(TMNote*)[ m_aNotesArray objectAtIndex:i] m_nStartNoteRow] == noteRow )
			return YES;
		else
			return NO;
	}
	
	return NO;
}

- (TMNote*) getNote:(int) index {
	return [m_aNotesArray objectAtIndex:index];
}

- (int) getNotesCount {
	return [m_aNotesArray count];
}

- (void) dealloc {
	[m_aNotesArray release];
	[super dealloc];
}

@end
