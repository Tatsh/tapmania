//
//  TMSteps.m
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMSteps.h"
#import "TMTrack.h"


@implementation TMSteps

- (id) init {
	self = [super init];
	if(!self) 
		return nil;
	
	int i;
	
	// Alloc space for tracks
	for(i=0; i<kNumOfAvailableTracks; i++){
		tracks[i] = [[TMTrack alloc] init];
	}
	
	return self;
}

- (int) getDifficultyLevel {
	return difficultyLevel;
}

- (TMSongDifficulty) getDifficulty {
	return difficulty;
}

- (void) setNote:(TMNote*) note toTrack:(int) trackIndex onNoteRow:(int) noteRow{
	[tracks[trackIndex] setNote:note onNoteRow:noteRow];
}

- (TMNote*) getNote:(int) index fromTrack:(int) trackIndex {
	return [tracks[trackIndex] getNote:index];
}

- (int) getNotesCountForTrack:(int) trackIndex {
	return [tracks[trackIndex] getNotesCount];
}

- (int) getFirstNoteRow {
	int i;
	int minNoteRow = INT_MAX;

	for(i=0; i<kNumOfAvailableTracks; i++){
		int j = 0;

		// Skip all empty notes
		while([(TMNote*)[tracks[i] getNote:j++] type] == kNoteType_Empty);

		// Get the smallest
		minNoteRow = (int) fminf( (float)minNoteRow, (float)[(TMNote*)[tracks[i] getNote:j] startNoteRow]);
	}

	return minNoteRow;
}

- (int) getLastNoteRow {
	int i;
	int maxNoteRow = 0;
	
	for(i=0; i<kNumOfAvailableTracks; i++){
		TMNote* lastNote = [tracks[i] getNote:[tracks[i] getNotesCount]-1];
		maxNoteRow = (int) fmaxf( (float)maxNoteRow, lastNote.type == kNoteType_HoldHead ? (float)[lastNote stopNoteRow] : (float)[lastNote startNoteRow]);
	}
	
	return maxNoteRow;
}


@end
