//
//  $Id$
//  SongResultsRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 21.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "SongResultsRenderer.h"

#import "TapMania.h"
#import "InputEngine.h"
#import "EAGLView.h"

#import "FontString.h"
#import "ThemeManager.h"

#import "TMSteps.h"
#import "SongPickerMenuRenderer.h"

#import "GameState.h"

extern TMGameState* g_pGameState;

@implementation SongResultsRenderer

- (void) dealloc {
	
	// Here we MUST release memory used by the steps since after this place we will not need it anymore
	[g_pGameState->m_pSteps release];
	[g_pGameState->m_pSong release];
	
	g_pGameState->m_pSong = nil;
	g_pGameState->m_pSteps = nil;
		
	for(int i=0; i<kNumJudgementValues; ++i) {
		[m_pJudgeScores[i] release];
	}
		
	[super dealloc];
}

/* TMTransitionSupport methods */
- (void) setupForTransition {
	[super setupForTransition];
	
	// Textures
	t_JudgeLabels = TEXTURE(@"SongResults JudgeLabels");
	
	// Get metrics
	for(int i=0; i<kNumJudgementValues; ++i) {
		NSString* k = [NSString stringWithFormat:@"SongResults JudgeLabelPositions %d",i];
		mt_JudgeLabels[i] = POINT_METRIC(k);
	}

	for(int i=0; i<kNumJudgementValues; ++i) {
		NSString* k = [NSString stringWithFormat:@"SongResults JudgeScorePositions %d",i];
		mt_JudgeScores[i] = POINT_METRIC(k);
	}
	
	int i, track;
	
	// asure we have zeros in all score counters
	for(i=0; i<kNumJudgementValues; i++) m_nCounters[i]=0;
	for(i=0; i<kNumHoldScores; i++) m_nOkNgCounters[i]=0;
	
	m_bReturnToSongSelection = NO;
	
	// Calculate
	for(track=0; track<kNumOfAvailableTracks; track++) {
		int notesCount = [g_pGameState->m_pSteps getNotesCountForTrack:track];
		
		for(i=0; i<notesCount; i++) {
			TMNote* note = [g_pGameState->m_pSteps getNote:i fromTrack:track];
			
			if(note.m_nType != kNoteType_Empty) {
				m_nCounters[ note.m_nScore ] ++;
				
				if(note.m_nType == kNoteType_HoldHead) {
					m_nOkNgCounters[ note.m_nHoldScore ] ++;
				}
			}
		}
	}
	
	// Create font strings
	for(int i=0; i<kNumJudgementValues; ++i) {
		if(i==6) {
			m_pJudgeScores[i] = [[FontString alloc] initWithFont:@"SongResults ScoreNormalNumbers"
														 andText:[NSString stringWithFormat:@"%4d",
															m_nOkNgCounters[kHoldScore_OK]]];
		} else {
			m_pJudgeScores[i] = [[FontString alloc] initWithFont:@"SongResults ScoreNormalNumbers" 
														 andText:[NSString stringWithFormat:@"%4d",m_nCounters[i]]];
		}
	}
}

/* TMRenderable method */
- (void) render:(float)fDelta {
	CGRect bounds = [TapMania sharedInstance].glView.bounds;	
	[super render:fDelta];

	// Draw stuff
	glEnable(GL_BLEND);

	for(int i=0; i<kNumJudgementValues; ++i) {
		[t_JudgeLabels drawFrame:i atPoint:mt_JudgeLabels[i]];
		[m_pJudgeScores[i] drawAtPoint:mt_JudgeScores[i]];
	}
	
	glDisable(GL_BLEND);
}

/* TMLogicUpdater stuff */
- (void) update:(float)fDelta {
	[super update:fDelta];
	
	if(m_bReturnToSongSelection) {
		[[TapMania sharedInstance] switchToScreen:[SongPickerMenuRenderer class] withMetrics:@"SongPickerMenu"];
		
		m_bReturnToSongSelection = NO;
	}
}

/* TMGameUIResponder methods */
- (BOOL) tmTouchesEnded:(const TMTouchesVec&)touches withEvent:(UIEvent*)event {
	if(touches.size() == 1) {		
		m_bReturnToSongSelection = YES;
	}
	
	return YES;
}

@end
