//
//  $Id$
//  SongResultsRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 21.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "TMNote.h" // For kNumNoteScores etc.

#import "TMScreen.h"

@class TMSteps, TMSong, FontString, TMFramedTexture;

@interface SongResultsRenderer : TMScreen {	
	int						m_nCounters[kNumJudgementValues];
	int						m_nOkNgCounters[kNumHoldScores];
	
	BOOL					m_bReturnToSongSelection;

	FontString*				m_pJudgeScores[kNumJudgementValues];

	// Metrics and cache
	CGPoint					mt_JudgeLabels[kNumJudgementValues];
	CGPoint					mt_JudgeScores[kNumJudgementValues];
	
	TMFramedTexture*		t_JudgeLabels;
}

@end
