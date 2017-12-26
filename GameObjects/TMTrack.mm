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
- (unsigned long) getNoteIndexFromRow:(long)noteRow;
@end

@implementation TMTrack

- (id) init {
	self = [super init];
	if (!self)
		return nil;

	m_aNotesArray = new TMNoteList();
	m_nTapAndHoldNotesCnt = 0;
	
	return self;
}

- (void) dealloc {
	delete m_aNotesArray;
	
	[super dealloc];
}

- (void) setNote:(TMNote*) note onNoteRow:(long)noteRow {
	unsigned long index = [self getNoteIndexFromRow:noteRow];
	TMLog(@"NoteRow to index %d == %d", noteRow, index);
	
	note.m_nStartNoteRow = noteRow;
	
	if(index != -1) {
		// The note must be replaced
		m_aNotesArray->at(index) = TMNotePtr(note);
		
	} else {
		// The note must be appended
		m_aNotesArray->push_back(note); 
	}
}

- (unsigned long) getNoteIndexFromRow:(long)noteRow {
	unsigned long low = 0;
	unsigned long high = m_aNotesArray->size();
	unsigned long mid;
	
	while(low < high) {
		mid = low + ((high-low)/2);
		if(m_aNotesArray->at(mid).get().m_nStartNoteRow < noteRow)
			low = mid+1;
		else
			high = mid;
	}
	
	if((low < m_aNotesArray->size()) && (m_aNotesArray->at(low).get().m_nStartNoteRow == noteRow)) {
		return low;
	}

	return -1;	
}

- (TMNote*) getNoteFromRow:(long)noteRow {
	unsigned long index = [self getNoteIndexFromRow:noteRow];
	
	if(index != -1)
		return [self getNote:index];
	
	return nil;
}

- (TMNote*) getNote:(unsigned long)index {
	if(index >= m_aNotesArray->size())
		return nil;

	TMNote* note = m_aNotesArray->at(index).get();
	return note;
}

- (BOOL) hasNoteAtRow:(long)noteRow {
	return ([self getNoteFromRow:noteRow] != nil);
}

- (unsigned long) getNotesCount {
	return m_aNotesArray->size();
}

- (int) getHoldsCount {
	if(m_nHoldsCnt == 0) {
		
		// Calculate and store
		for(TMNoteList::iterator it = m_aNotesArray->begin(); it!=m_aNotesArray->end(); ++it) {
			
			if( [(TMNote*)(*it).get() m_nType] == kNoteType_HoldHead ) {
				++m_nHoldsCnt;
			}
		}
	}
	
	return m_nHoldsCnt;
}

- (int) getTapAndHoldNotesCount {
	if(m_nTapAndHoldNotesCnt == 0) {

		// Calculate and store
		for(TMNoteList::iterator it = m_aNotesArray->begin(); it!=m_aNotesArray->end(); ++it) {
			
			if( [(TMNote*)(*it).get() m_nType] == kNoteType_HoldHead ||
				[(TMNote*)(*it).get() m_nType] == kNoteType_Original ) {
				++m_nTapAndHoldNotesCnt;
			}
		}
	}
	
	return m_nTapAndHoldNotesCnt;
}


@end
