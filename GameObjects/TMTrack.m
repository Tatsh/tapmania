//
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
	
	// Alloc space for the initial notes array
	m_nCurrentCapacity = kDefaultTrackCapacity;
	m_aNotesArray = (TMNote**)malloc(sizeof(TMNote*) * m_nCurrentCapacity);
	
	int i;
	for(i=0; i<m_nCurrentCapacity; ++i) {
		m_aNotesArray[i] = NULL;
	}
	
	m_nTotalNotes = 0;
	
	return self;
}

- (void) dealloc {
	free(m_aNotesArray);
	[super dealloc];
}

- (void) setNote:(TMNote*) note onNoteRow:(int)noteRow {
	if(m_nTotalNotes >= m_nCurrentCapacity) {
		m_nCurrentCapacity += kDefaultTrackCapacity;		// add new positions
		m_aNotesArray = (TMNote**)realloc(m_aNotesArray, sizeof(TMNote*) * m_nCurrentCapacity);
		
		// clean
		int i;
		for(i=m_nTotalNotes; i<m_nCurrentCapacity; ++i) {
			m_aNotesArray[i] = NULL;
		}
	}

	int index = [self getNoteIndexFromRow:noteRow];
	if(index != -1) {
		// The note must be replaced
		m_aNotesArray[index] = note;
		
	} else {
		// The note must be appended
		m_aNotesArray[m_nTotalNotes++] = note;			
	}
	
	note.m_nStartNoteRow = noteRow;
}

- (int) getNoteIndexFromRow:(int)noteRow {
	int low = 0;
	int high = m_nTotalNotes;
	int mid;
	
	while(low < high) {
		mid = low + ((high-low)/2);
		if(m_aNotesArray[mid].m_nStartNoteRow < noteRow)
			low = mid+1;
		else
			high = mid;
	}
	
	if((low < m_nTotalNotes) && (m_aNotesArray[low].m_nStartNoteRow == noteRow))
		return low;
	
	return -1;	
}

- (TMNote*) getNoteFromRow:(int)noteRow {	
	int index = [self getNoteIndexFromRow:noteRow];
	
	if(index != -1)
		return m_aNotesArray[index];
	
	return nil;
}

- (TMNote*) getNote:(int)index {
	if(index >= m_nTotalNotes)
		return nil;

	return m_aNotesArray[index];
}

- (BOOL) hasNoteAtRow:(int)noteRow {
	return ([self getNoteFromRow:noteRow] != nil);
}

- (int) getNotesCount {
	return m_nTotalNotes;
}

@end
