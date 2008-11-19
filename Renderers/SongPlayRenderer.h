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
#import "JoyPad.h"

@interface SongPlayRenderer : AbstractRenderer {
	TMSong*					song;	// Currently played song
	TMSteps*				steps;	// Currently played steps

	JoyPad*					joyPad; // A pointer to the AppDelegate's joyPad for easy access
	
	int						trackPos[kNumOfAvailableTracks];	// Current element of each track
	
	double					speedModValue;
	
	double					playBackStartTime;
	double					bpmSpeed;
	double					fullScreenTime;
	double					timePerBeat;	//Current time per beat value (bpm change will change this)
	
	BOOL					gapIsDone;	// Specifies whether the gap offset is handled already or not
}

- (void) playSong:(TMSong*) lSong withOptions:(TMSongOptions*) options;

@end
