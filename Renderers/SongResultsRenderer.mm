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

@interface SongResultsRenderer(Private)
- (TMGrade) gradeFromScore:(long)score fromMaxScore:(long)maxScore;
@end


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
	
	[m_pScore release];
	[m_pMaxCombo release];
	g_pGameState->m_nScore = g_pGameState->m_nCombo = 0;
	
	[super dealloc];
}

/* TMTransitionSupport methods */
- (void) setupForTransition {
	[super setupForTransition];
	
	// Textures
	t_JudgeLabels = TEXTURE(@"SongResults JudgeLabels");
	t_Grades	= TEXTURE(@"SongResults Grades");
	
	// Get metrics
	for(int i=0; i<kNumJudgementValues; ++i) {
		NSString* k = [NSString stringWithFormat:@"SongResults JudgeLabelPositions %d",i];
		mt_JudgeLabels[i] = POINT_METRIC(k);
	}

	for(int i=0; i<kNumJudgementValues; ++i) {
		NSString* k = [NSString stringWithFormat:@"SongResults JudgeScorePositions %d",i];
		mt_JudgeScores[i] = POINT_METRIC(k);
	}
	
	mt_MaxCombo = POINT_METRIC(@"SongResults MaxCombo");
	mt_MaxComboLabel = POINT_METRIC(@"SongResults MaxComboLabelPosition");
	
	mt_Score = POINT_METRIC(@"SongResults Score");
	mt_Grade = POINT_METRIC(@"SongResults Grade");
	
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
	
	m_pScore = [[FontString alloc] initWithFont:@"SongResults ScoreNormalNumbers" 
								andText:[NSString stringWithFormat:@"%9ld",
									g_pGameState->m_nScore]];
	[m_pScore setAlignment:UITextAlignmentCenter];
	
	m_pMaxCombo = [[FontString alloc] initWithFont:@"SongResults ScoreNormalNumbers" 
										   andText:[NSString stringWithFormat:@"%4d",
													g_pGameState->m_nCombo]];
	
	if(g_pGameState->m_bFailed) {
		m_Grade = kGradeE;
		
	} else if(m_nCounters[kJudgementW1] == [g_pGameState->m_pSteps getTotalTapAndHoldNotes]) {
		
		m_Grade = kGradeAAAA;
		
	} else if(m_nCounters[kJudgementW3] == 0 && m_nCounters[kJudgementW4] == 0
			  && m_nCounters[kJudgementW5] == 0 && m_nCounters[kJudgementMiss] == 0) {
		
		m_Grade = kGradeAAA;
		
	} else {
		
		m_Grade = [self gradeFromScore:g_pGameState->m_nScore 
						  fromMaxScore:[g_pGameState->m_pSteps getDifficultyLevel]*10000000];
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
	
	[t_JudgeLabels drawFrame:kNumJudgementValues atPoint:mt_MaxComboLabel];
	[m_pMaxCombo drawAtPoint:mt_MaxCombo];
	[m_pScore drawAtPoint:mt_Score];
	[t_Grades drawFrame:(int)m_Grade atPoint:mt_Grade];
	
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


- (TMGrade) gradeFromScore:(long)score fromMaxScore:(long)maxScore {
	float percent = (float)score/(float)maxScore;
	
	if(percent >= .95f) {
		return kGradeAA;
	}
	else if(percent >= .80f) {
		return kGradeA;
	}
	else if(percent >= .70f) {
		return kGradeB;
	}
	else if(percent >= .60f) {
		return kGradeC;
	}
	else 
		return kGradeD;
}


@end
