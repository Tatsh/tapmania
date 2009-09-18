//
//  SongResultsRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 21.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "TMNote.h" // For kNumNoteScores etc.

#import "TMScreen.h"

@class TMSteps, TMSong, Texture2D;

@interface SongResultsRenderer : TMScreen {	
	int						m_nCounters[kNumJudgementValues];
	int						m_nOkNgCounters[kNumHoldScores];
	
	BOOL					m_bReturnToSongSelection;
	
	NSMutableArray* texturesArray;
	
	/* Metrics and such */	
	Texture2D* t_SongResultsBG;
}

@end
