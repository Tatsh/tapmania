//
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

#import "Texture2D.h"
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
	
	int i;
	for(i=0; i<[texturesArray count]; ++i) {
		[[texturesArray objectAtIndex:i] release];
	}
	
	[texturesArray release];
	
	[super dealloc];
}

/* TMTransitionSupport methods */
- (void) setupForTransition {
	[super setupForTransition];
	
	// Cache textures
	t_SongResultsBG = TEXTURE(@"SongResults Background");

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
	
	// Alloc the textures array
	texturesArray = [[NSMutableArray alloc] initWithCapacity:8];
	
	// Cache the textures
	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"Marvelous: %d", m_nCounters[kJudgementW1]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:24]];
	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"Perfect: %d", m_nCounters[kJudgementW2]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:24]];
	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"Great: %d", m_nCounters[kJudgementW3]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:24]];
	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"Good: %d", m_nCounters[kJudgementW4]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:24]];
	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"Boo: %d", m_nCounters[kJudgementW5]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:24]];
	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"Miss: %d", m_nCounters[kJudgementMiss]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:24]];
	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"OK: %d", m_nOkNgCounters[kHoldScore_OK]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:24]];
//	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"NG: %d", m_nOkNgCounters[kHoldScore_NG]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:24]];	
	
	// Subscribe for input events
	[[InputEngine sharedInstance] subscribe:self];
}

- (void) deinitOnTransition {
	[super deinitOnTransition];
	
	// Unsubscribe from input events
	[[InputEngine sharedInstance] unsubscribe:self];
}

/* TMRenderable method */
- (void) render:(float)fDelta {
	CGRect bounds = [TapMania sharedInstance].glView.bounds;
	
	// Draw background
	[t_SongResultsBG drawInRect:bounds];	
	[super render:fDelta];
	
	// Draw texts	
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	int i;
	
	for(i=0; i<[texturesArray count]; i++){
		[[texturesArray objectAtIndex:i] drawInRect:CGRectMake(0, 320-(i*30), 320, 30)];
	}
	
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);	
	glDisable(GL_BLEND);
}

/* TMLogicUpdater stuff */
- (void) update:(float)fDelta {
	[super update:fDelta];
	
	if(m_bReturnToSongSelection) {
		SongPickerMenuRenderer* spRenderer = [[SongPickerMenuRenderer alloc] init];
		[[TapMania sharedInstance] switchToScreen:spRenderer];
		
		m_bReturnToSongSelection = NO;
	}
}

/* TMGameUIResponder methods */
- (void) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	if([touches count] == 1){	
		m_bReturnToSongSelection = YES;
	}
}

@end
