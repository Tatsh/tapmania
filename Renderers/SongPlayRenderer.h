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
#import "HoldJudgement.h"

#define kMinTimeTillStart 3.0	// 3 seconds till start of first beat
#define kTimeTillMusicStop 3.0  // 3 seconds from last beat hit the receptor row

@interface SongPlayRenderer : AbstractRenderer <TMLogicUpdater> {
	TMSong*					m_pSong;	// Currently played song
	TMSteps*				m_pSteps;	// Currently played steps

	ReceptorRow*			m_pReceptorRow;
	LifeBar*				m_pLifeBar;
	
	int						m_nTrackPos[kNumOfAvailableTracks];	// Current element of each track
	
	double					m_dSpeedModValue;	
	double					m_dPlayBackStartTime;			// The time to start music
	double					m_dPlayBackScheduledEndTime;	// The time to stop music and stop gameplay
	
	BOOL					m_bPlayingGame;
	BOOL					m_bMusicPlaybackStarted;

	JoyPad* 				m_pJoyPad; // Local pointer for easy access
}

- (void) playSong:(TMSong*) song withOptions:(TMSongOptions*) options;

@end
