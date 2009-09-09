//
//  SongPlayRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AbstractRenderer.h"
#import "TMLogicUpdater.h"
#import "TMTransitionSupport.h"

#import "TMSteps.h" // For kNumOfAvailableTracks

@class TMSound, TMSong, TMSongOptions, TMSteps, ReceptorRow, LifeBar, JoyPad;

#define kMinTimeTillStart 3.0	// 3 seconds till start of first beat

/*
  If the first beat will appear at minimum 3 seconds after gameplay entrance..
  The Ready sprite must appear directly and Go sprite should appear in 1 seconds
  Then 'Go' sprite should go away before the first arrow hits the receptor
  Thus Go sprite must be shown for 1 second too. That will make another second free for the player.
 */

#define kReadySpriteTime 1.0
#define kGoSpriteTime 1.0

#define kTimeTillMusicStop 3.0  // 3 seconds from last beat hit the receptor row
#define kFadeOutTime	3.0		// 3 seconds fade duration

#define kMinLifeToKeepAlive 0.03

@interface SongPlayRenderer : AbstractRenderer <TMLogicUpdater, TMTransitionSupport> {
	TMSound*				m_pSound;	// TMSound object with sound
	TMSong*					m_pSong;	// Currently played song
	TMSteps*				m_pSteps;	// Currently played steps

	ReceptorRow*			m_pReceptorRow;
	LifeBar*				m_pLifeBar;
	
	int						m_nTrackPos[kNumOfAvailableTracks];	// Current element of each track
	
	double					m_dSpeedModValue;	
	double					m_dPlayBackStartTime;				// The time to start music
	double					m_dPlayBackScheduledEndTime;		// The time to stop music and stop gameplay
	double					m_dPlayBackScheduledFadeOutTime;	// The time to start fading music out
	
	BOOL					m_bPlayingGame;
	BOOL					m_bFailed;
	BOOL					m_bDrawReady, m_bDrawGo;
	BOOL					m_bIsFading;
	BOOL					m_bMusicPlaybackStarted;
	
	BOOL					m_bAutoPlay;

	JoyPad* 				m_pJoyPad; // Local pointer for easy access
}

- (void) playSong:(TMSong*) song withOptions:(TMSongOptions*) options;

@end
