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
#import "TMLogicUpdater.h"
#import "JoyPad.h"
#import "ReceptorRow.h"
#import "LifeBar.h"
#import "HoldNote.h"
#import "Judgement.h"

#define kMinTimeTillStart 3.0	// 3 seconds till start of first beat
#define kTimeTillMusicStop 3.0  // 3 seconds from last beat hit the receptor row

@interface SongPlayRenderer : AbstractRenderer <TMLogicUpdater> {
	TMSong*					song;	// Currently played song
	TMSteps*				steps;	// Currently played steps

	ReceptorRow*			receptorRow;
	LifeBar*				lifeBar;
	
	int						trackPos[kNumOfAvailableTracks];	// Current element of each track
	
	double					speedModValue;	
	double					playBackStartTime;			// The time to start music
	double					playBackScheduledEndTime;	// The time to stop music and stop gameplay
	
	BOOL					playingGame;
	BOOL					musicPlaybackStarted;

	JoyPad* 				joyPad; // Local pointer for easy access
}

- (void) playSong:(TMSong*) lSong withOptions:(TMSongOptions*) options;

@end
