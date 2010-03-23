/*
 *  $Id$
 *  GameState.h
 *  TapMania
 *
 *  Created by Alex Kremer on 15.09.09.
 *  Copyright 2009 Godexsoft. All rights reserved.
 *
 *  This is a global structure which represents the current gamestate values.
 *  It's done as a plain C struct for faster access
 */

#import "TMSong.h"
@class TMSong, TMSteps;

typedef struct TapManiaGameState {
		
	TMSong*					m_pSong;	// Current song
	TMSteps*				m_pSteps;	// Currently played steps
	
	double					m_dElapsedTime;			// Elapsed time since start of beats counting
	double					m_dPlayBackStartTime;	// Time of gameplay start
	
	/* Global modifiers */
	double					m_dSpeedModValue;		// Speed modifier value
	BOOL					m_bAutoPlay;			// Autoplay setting
	TMFailType				m_nFailType;			// Fail type (off, on, at end)
	TMSongDifficulty        m_nSelectedDifficulty;	// Difficulty setting
	
	BOOL					m_bPlayingGame;
	BOOL					m_bFailed;
	BOOL					m_bGaveUp;
	BOOL					m_bMusicPlaybackStarted;
	
	BOOL					m_bLandscape;
	
	/* Score and combo results */
	long					m_nScore;
	int						m_nCombo;
	
} TMGameState;
