//
//  SongResultsRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 21.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "TMNote.h" // For kNumNoteScores etc.

#import "TMScreen.h"
#import "TMGameUIResponder.h"

@class TMSteps, TMSong, Texture2D;

@interface SongResultsRenderer : TMScreen <TMGameUIResponder> {
	TMSong*					m_pSong;	// The song we are calculating for
	TMSteps*				m_pSteps;	// The steps we played
	
	int						m_nCounters[kNumNoteScores];
	int						m_nOkNgCounters[kNumNoteScores];
	
	BOOL					m_bReturnToSongSelection;
	
	NSMutableArray* texturesArray;
	
	/* Metrics and such */	
	Texture2D* t_SongResultsBG;
}

- (id) initWithSong:(TMSong*)song withSteps:(TMSteps*)steps;

@end
