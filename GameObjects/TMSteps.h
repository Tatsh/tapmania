//
//  TMSteps.h
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMSong.h"
#import "TMNote.h"
#import "TMTrack.h"

typedef enum {
	kAvailableTrack_Left = 0,
	kAvailableTrack_Down,
	kAvailableTrack_Up,
	kAvailableTrack_Right,
	kNumOfAvailableTracks
} TMAvailableTracks;

@interface TMSteps : NSObject {
	TMSongDifficulty	m_nDifficulty;						// The difficulty. eg. Easy, Heavy etc.
	int					m_nDifficultyLevel;					// The level. eg. 1-15.
	
	TMTrack*			m_pTracks[kNumOfAvailableTracks];	// We have 4 tracks which represent 4 different positions of feet
}

- (int) getDifficultyLevel;
- (TMSongDifficulty) getDifficulty;

- (void) setNote:(TMNote*) note toTrack:(int) trackIndex onNoteRow:(int) idx;
- (TMNote*) getNote:(int) index fromTrack:(int) trackIndex;
- (TMNote*) getNoteFromRow:(int) noteRow forTrack:(int) trackIndex;
- (BOOL) hasNoteAtRow:(int) noteRow forTrack:(int) trackIndex;
- (int) getNotesCountForTrack:(int) trackIndex;

- (BOOL) checkAllNotesHitFromRow:(int) noteRow time1Out:(double*)time1Out time2Out:(double*)time2Out time3Out:(double*)time3Out time4Out:(double*)time4Out;
- (void) markAllNotesLostFromRow:(int) noteRow;

- (int) getFirstNoteRow;
- (int) getLastNoteRow;

@end
