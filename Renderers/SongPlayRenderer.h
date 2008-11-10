//
//  SongPlayRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractRenderer.h"

#import "TMSong.h"
#import "TMSteps.h"
#import "TMSongOptions.h"

@interface SongPlayRenderer : AbstractRenderer {
	TMSong*					song;	// Currently played song
	TMSteps*				steps;	// Currently played steps
	
	int						trackPos[kNumOfAvailableTracks];	// Current element of each track
	
	unsigned				_combo;  // Current combo
	unsigned				_score;  // Current score
	
	double					playBackStartTime;
	double					bpmSpeed;
	
	// JUST FOR TEST!!!
	float arrowPos;
	BOOL gapDone;
}

- (void) playSong:(TMSong*) lSong onDifficulty:(TMSongDifficulty)difficulty withOptions:(TMSongOptions*) options;

@end
