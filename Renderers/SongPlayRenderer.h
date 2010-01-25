//
//  $Id$
//  SongPlayRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMScreen.h"
#import "TMSteps.h" // For kNumOfAvailableTracks
#import "TMMessageSupport.h"

@class TMSound, TMSong, TMSongOptions, TMSteps, ReceptorRow, LifeBar, JoyPad, ComboMeter;
@class Judgement, HoldJudgement, TapNote, HoldNote, Texture2D;

#define kMinTimeTillStart 3.0	// 3 seconds till start of first beat
#define kReadySpriteTime 1.5
#define kGoSpriteTime 1.2

#define kTimeTillMusicStop 3.0  // 3 seconds from last beat hit the receptor row
#define kFadeOutTime	3.0		// 3 seconds fade duration

@interface SongPlayRenderer : TMScreen <TMMessageSupport> {
	TMSound*				m_pSound;	// TMSound object with sound

	ReceptorRow*			m_pReceptorRow;
	LifeBar*				m_pLifeBar;
	
	double					m_dScreenEnterTime;					// The time when we invoked playSong
	double					m_dPlayBackScheduledEndTime;		// The time to stop music and stop gameplay
	double					m_dPlayBackScheduledFadeOutTime;	// The time to start fading music out
	
	BOOL					m_bDrawReady, m_bDrawGo;
	BOOL					m_bIsFading;
	BOOL					m_bMusicPlaybackStarted;
	
	JoyPad* 				m_pJoyPad; // Local pointer for easy access
	
	/* Metrics and such */
	// Theme stuff
	Judgement*	t_Judgement;
	HoldJudgement* t_HoldJudgement;
	ComboMeter*		t_ComboMeter;
	
	// Other
	Texture2D* t_FingerTap;
	Texture2D* t_Failed, *t_Cleared, *t_Ready, *t_Go;
	
	// Sounds
	TMSound   *sr_Failed, *sr_Cleared;
	
	CGPoint mt_Judgement;
	float   mt_JudgementMaxShowTime;
	
	CGRect mt_LifeBar;
		
	BOOL cfg_VisPad;
}

- (void) playSong;

@end
