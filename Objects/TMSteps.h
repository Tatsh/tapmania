//
//  TMSteps.h
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMSong.h"

typedef enum {
	kAvailableTrack_Left = 0,
	kAvailableTrack_Right,
	kAvailableTrack_Up,
	kAvailableTrack_Down,
	kNumOfAvailableTracks
} TMAvailableTracks;

@interface TMSteps : NSObject {
	TMSongDifficulty	difficulty;						// The difficulty. eg. Easy, Heavy etc.
	int					difficultyLevel;				// The level. eg. 1-15.
	
	NSMutableArray*		tracks[kNumOfAvailableTracks];	// We have 4 tracks which represent 4 different positions of feet
}

// The constructor which is used. will parse the original stepmania file to determine steps info for the given level.
- (id) initWithFile:(NSString*) filename;

- (int) getDifficultyLevel;
- (TMSongDifficulty) getDifficulty;

// TODO: define routines to work with the actual step data in the structures

@end
