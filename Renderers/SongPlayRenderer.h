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

@class TMSound, TMSong, TMSongOptions, TMSteps, ReceptorRow, LifeBar, JoyPad, ComboMeter, ScoreMeter;
@class Judgement, HoldJudgement, TapNote, HoldNote, Texture2D, TMFramedTexture;
@class Sprite;

#define kMinTimeTillStart 3.0	// 3 seconds till start of first beat

#define kTimeTillMusicStop 3.0  // 3 seconds from last beat hit the receptor row
#define kFadeOutTime	3.0		// 3 seconds fade duration

@interface SongPlayRenderer : TMScreen <TMMessageSupport> {
	TMSound*				m_pSound;	// TMSound object with sound

	ReceptorRow*			m_pReceptorRow;
	LifeBar*				m_pLifeBar;
	ComboMeter*				m_pComboMeter;
	ScoreMeter*				m_pScoreMeter;
	
	double					m_dScreenEnterTime;					// The time when we invoked playSong
	double					m_dPlayBackScheduledEndTime;		// The time to stop music and stop gameplay
	double					m_dPlayBackScheduledFadeOutTime;	// The time to start fading music out
	double					m_dFailedTime, m_dClearedTime;
	
	BOOL					m_bDrawReady, m_bDrawGo, m_bDrawnGo, m_bDrawFailed, m_bDrawCleared;
	BOOL					m_bWarningMode;
	BOOL					m_bIsFading;
	BOOL					m_bMusicPlaybackStarted;
	
	JoyPad* 				m_pJoyPad; // Local pointer for easy access
	
	/* Metrics and such */
	// Theme stuff
	Judgement*	t_Judgement;
	HoldJudgement* t_HoldJudgement;
	
	// Other
	TMFramedTexture* t_FingerTap;
	Texture2D* t_Failed, *t_Cleared, *t_Ready, *t_Go;
	Sprite* m_sprWarning;
	
	// Sounds
	TMSound   *sr_Failed, *sr_Cleared;
	
	CGPoint mt_Judgement;
	float   mt_JudgementMaxShowTime;
	float   mt_FailedMaxShowTime;
	float   mt_ClearedMaxShowTime;
	float	mt_GoShowTime, mt_ReadyShowTime;
	
	CGRect mt_LifeBar;
	
	CGPoint mt_Go, mt_Ready, mt_Failed, mt_Cleared, mt_Warning;
		
	BOOL cfg_VisPad;
}

- (void) playSong;

@end
