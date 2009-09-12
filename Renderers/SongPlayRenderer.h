//
//  SongPlayRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMScreen.h"
#import "TMSteps.h" // For kNumOfAvailableTracks
#import "TMMessageSupport.h"

@class TMSound, TMSong, TMSongOptions, TMSteps, ReceptorRow, LifeBar, JoyPad;
@class Judgement, HoldJudgement, TapNote, HoldNote, Texture2D;

#define kMinTimeTillStart 3.0	// 3 seconds till start of first beat
#define kReadySpriteTime 1.5
#define kGoSpriteTime 1.2

#define kTimeTillMusicStop 3.0  // 3 seconds from last beat hit the receptor row
#define kFadeOutTime	3.0		// 3 seconds fade duration

@interface SongPlayRenderer : TMScreen <TMMessageSupport> {
	TMSound*				m_pSound;	// TMSound object with sound
	TMSong*					m_pSong;	// Currently played song
	TMSteps*				m_pSteps;	// Currently played steps

	ReceptorRow*			m_pReceptorRow;
	LifeBar*				m_pLifeBar;
	
	int						m_nTrackPos[kNumOfAvailableTracks];	// Current element of each track
	
	double					m_dSpeedModValue;	
	double					m_dScreenEnterTime;					// The time when we invoked playSong
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
	
	/* Metrics and such */
	// Theme stuff
	Judgement*	t_Judgement;
	HoldJudgement* t_HoldJudgement;
	
	// Noteskin stuff
	TapNote* t_TapNote;
	HoldNote* t_HoldNoteInactive, *t_HoldNoteActive;
	Texture2D* t_HoldBottomCapActive, *t_HoldBottomCapInactive;
	Texture2D* t_FingerTap;
	Texture2D* t_BG, *t_Failed, *t_Cleared, *t_Ready, *t_Go;
	
	// Sounds
	TMSound   *sr_Failed, *sr_Cleared;
	
	CGPoint mt_Judgement;
	float   mt_JudgementMaxShowTime;
	
	CGSize mt_HoldCap, mt_HoldBody;
	CGRect mt_Receptors[kNumOfAvailableTracks];
	CGRect mt_LifeBar;
	
	CGRect mt_TapNotes[kNumOfAvailableTracks];
	float  mt_TapNoteRotations[kNumOfAvailableTracks];
	
	float mt_HalfOfArrowHeight[kNumOfAvailableTracks];
	
	BOOL cfg_VisPad;
}

- (void) playSong:(TMSong*) song withOptions:(TMSongOptions*) options;

@end
