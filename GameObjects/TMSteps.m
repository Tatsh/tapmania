//
//  TMSteps.m
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMSteps.h"
#import "TMTrack.h"
#import "TMNote.h"

@implementation TMSteps

- (id) init {
	self = [super init];
	if(!self) 
		return nil;
	
	int i;
	
	// Alloc space for tracks
	for(i=0; i<kNumOfAvailableTracks; i++){
		m_pTracks[i] = [[TMTrack alloc] init];
	}
	
	return self;
}

- (int) getDifficultyLevel {
	return m_nDifficultyLevel;
}

- (TMSongDifficulty) getDifficulty {
	return m_nDifficulty;
}

- (void) setNote:(TMNote*) note toTrack:(int) trackIndex onNoteRow:(int) noteRow{
	[m_pTracks[trackIndex] setNote:note onNoteRow:noteRow];
}

- (TMNote*) getNote:(int) index fromTrack:(int) trackIndex {
	return [m_pTracks[trackIndex] getNote:index];
}

- (TMNote*) getNoteFromRow:(int) noteRow forTrack:(int) trackIndex {
	return [m_pTracks[trackIndex] getNoteFromRow:noteRow];
}

- (BOOL) hasNoteAtRow:(int) noteRow forTrack:(int) trackIndex {
	return [m_pTracks[trackIndex] hasNoteAtRow:noteRow];
}

- (int) getNotesCountForTrack:(int) trackIndex {
	return [m_pTracks[trackIndex] getNotesCount];
}

// Time out stuff should be a pointer to array of kNumOfAvailableTracks elements but obj-c doesn't like the C syntax. FIXME
- (BOOL) checkAllNotesHitFromRow:(int) noteRow time1Out:(double*)time1Out time2Out:(double*)time2Out time3Out:(double*)time3Out time4Out:(double*)time4Out {
	// Check whether other tracks has any notes which are not hit yet and are on the same noterow
	BOOL allNotesHit = YES;
	int tr = 0;
	double* arrp[kNumOfAvailableTracks] = { time1Out, time2Out, time3Out, time4Out };
	
	for(; tr<kNumOfAvailableTracks; ++tr) {
	
		*(arrp[tr]) = 0.0f;
		TMNote* n = [self getNoteFromRow:noteRow forTrack:tr];
		
		// If found - check
		if(n != nil) {
			if(!n.m_bIsHit) {
				allNotesHit = NO;
			} else {
				*(arrp[tr]) = n.m_dHitTime;
			}
		}
	}
	
	return allNotesHit;
}

- (void) markAllNotesLostFromRow:(int) noteRow {
	int tr = 0;
	for(; tr<kNumOfAvailableTracks; ++tr) {
		
		TMNote* n = [self getNoteFromRow:noteRow forTrack:tr];
		
		// If found - check
		if(n != nil) {
			[n markLost];
		}
	}
}


- (int) getFirstNoteRow {
	int i;
	int minNoteRow = INT_MAX;

	for(i=0; i<kNumOfAvailableTracks; i++){
		int j = 0;

		// Skip all empty notes
		while([(TMNote*)[m_pTracks[i] getNote:j++] m_nType] == kNoteType_Empty);

		// Get the smallest
		minNoteRow = (int) fminf( (float)minNoteRow, (float)[(TMNote*)[m_pTracks[i] getNote:j] m_nStartNoteRow]);
	}

	return minNoteRow;
}

- (int) getLastNoteRow {
	int i;
	int maxNoteRow = 0;
	
	for(i=0; i<kNumOfAvailableTracks; i++){
		TMNote* lastNote = [m_pTracks[i] getNote:[m_pTracks[i] getNotesCount]-1];
		maxNoteRow = (int) fmaxf( (float)maxNoteRow, lastNote.m_nType == kNoteType_HoldHead ? (float)[lastNote m_nStopNoteRow] : (float)[lastNote m_nStartNoteRow]);
	}
	
	return maxNoteRow;
}


@end
