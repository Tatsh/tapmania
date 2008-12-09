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
	TMSongDifficulty	difficulty;						// The difficulty. eg. Easy, Heavy etc.
	int					difficultyLevel;				// The level. eg. 1-15.
	
	TMTrack*			tracks[kNumOfAvailableTracks];	// We have 4 tracks which represent 4 different positions of feet
}

- (int) getDifficultyLevel;
- (TMSongDifficulty) getDifficulty;

- (void) setNote:(TMNote*) note toTrack:(int) trackIndex onNoteRow:(int) idx;
- (TMNote*) getNote:(int) index fromTrack:(int) trackIndex;
- (int) getNotesCountForTrack:(int) trackIndex;

- (int) getFirstNoteRow;
- (int) getLastNoteRow;

@end
