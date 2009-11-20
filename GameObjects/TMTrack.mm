//
//  $Id$
//  TMTrack.m
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMTrack.h"
#import "TMNote.h"

@interface TMTrack (Private)
- (int) getNoteIndexFromRow:(int)noteRow;
@end

@implementation TMTrack

- (id) init {
	self = [super init];
	if (!self)
		return nil;

	m_aNotesArray = new TMNoteList();

	return self;
}

- (void) dealloc {
	delete m_aNotesArray;
	
	[super dealloc];
}

- (void) setNote:(TMNote*) note onNoteRow:(int)noteRow {	
	int index = [self getNoteIndexFromRow:noteRow];
	TMLog(@"NoteRow to index %d == %d", noteRow, index);
	
	note.m_nStartNoteRow = noteRow;
	
	if(index != -1) {
		// The note must be replaced
		[m_aNotesArray->at(index) release];
		m_aNotesArray->at(index) = note;
		
	} else {
		// The note must be appended
		m_aNotesArray->push_back(note); 
	}
}

- (int) getNoteIndexFromRow:(int)noteRow {	
	int low = 0;
	int high = m_aNotesArray->size();
	int mid;
	
	while(low < high) {
		mid = low + ((high-low)/2);
		if(m_aNotesArray->at(mid).m_nStartNoteRow < noteRow)
			low = mid+1;
		else
			high = mid;
	}
	
	if((low < m_aNotesArray->size()) && (m_aNotesArray->at(low).m_nStartNoteRow == noteRow)) {
		return low;
	}

	return -1;	
}

- (TMNote*) getNoteFromRow:(int)noteRow {	
	int index = [self getNoteIndexFromRow:noteRow];
	
	if(index != -1)
		return [self getNote:index];
	
	return nil;
}

- (TMNote*) getNote:(int)index {
	if(index >= m_aNotesArray->size())
		return nil;

	TMNote* note = m_aNotesArray->at(index);
	return note;
}

- (BOOL) hasNoteAtRow:(int)noteRow {
	return ([self getNoteFromRow:noteRow] != nil);
}

- (int) getNotesCount {
	return m_aNotesArray->size();
}

@end
