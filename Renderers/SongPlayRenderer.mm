//
//  $Id$
//  SongPlayRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "SongPlayRenderer.h"
#import "TapManiaAppDelegate.h"
#import "TMSoundEngine.h"
#import "TMSound.h"
#import "TimingUtil.h"
#import "PhysicsUtil.h"
#import "SongsDirectoryCache.h"
#import "DWIParser.h"

#import "NewsFetcher.h"
#import "SongResultsRenderer.h"

#import "TMSong.h"
#import "TMTrack.h"
#import "TMChangeSegment.h"

#import "ReceptorRow.h"
#import "LifeBar.h"
#import "ComboMeter.h"
#import "ScoreMeter.h"

#import "SettingsEngine.h"
#import "ThemeManager.h"
#import "TapMania.h"
#import "EAGLView.h"
#import "JoyPad.h"
#import "GLUtil.h"
#import "TMFramedTexture.h"

#import "TapNote.h"
#import "HoldNote.h"
#import "HoldJudgement.h"
#import "Judgement.h"

#import "MessageManager.h"
#import "TMMessage.h"

#import "GameState.h"

#import <math.h>

extern TMGameState* g_pGameState;

@interface SongPlayRenderer (Private)
-(void) fade;
@end

@implementation SongPlayRenderer

- (id) initWithMetrics:(NSString*)inMetrics {
	self = [super initWithMetrics:inMetrics];
	if(!self)
		return nil;
		
	// Register message types
	REG_MESSAGE(kNoteScoreMessage, @"NoteScoring");
	REG_MESSAGE(kHoldLostMessage, @"HoldIsLost");
	REG_MESSAGE(kHoldHeldMessage, @"HoldIsHeld");
	
	// Disallow news system updates
	[[NewsFetcher sharedInstance] stopChecking];
	
	// Cache metrics
	mt_Judgement =							POINT_METRIC(@"SongPlay Judgement");
	mt_JudgementMaxShowTime =				FLOAT_METRIC(@"SongPlay Judgement MaxShowTime");
	
	mt_LifeBar =							RECT_METRIC(@"SongPlay LifeBar");
	
	cfg_VisPad =							CFG_BOOL(@"vispad");
	
	mt_Cleared =							POINT_METRIC(@"SongPlay Cleared");
	mt_Failed =								POINT_METRIC(@"SongPlay Failed");
	mt_Ready =								POINT_METRIC(@"SongPlay Ready");
	mt_Go	=								POINT_METRIC(@"SongPlay Go");
	
	mt_FailedMaxShowTime =					FLOAT_METRIC(@"SongPlay Failed MaxShowTime");
	mt_ClearedMaxShowTime =					FLOAT_METRIC(@"SongPlay Cleared MaxShowTime");

	// Cache graphics
	t_Judgement = (Judgement*)TEXTURE(@"SongPlay Judgement");
	t_HoldJudgement = (HoldJudgement*)TEXTURE(@"SongPlay HoldJudgement");	
	
	t_FingerTap = (TMFramedTexture*)TEXTURE(@"Common FingerTapG");
	t_BG = TEXTURE(@"SongPlay Background");
	t_Failed = TEXTURE(@"SongPlay Failed");
	t_Cleared = TEXTURE(@"SongPlay Cleared");
	
	t_Ready = TEXTURE(@"SongPlay Ready");
	t_Go = TEXTURE(@"SongPlay Go");
	mt_ReadyShowTime = FLOAT_METRIC(@"SongPlay Ready ShowTime");
	mt_GoShowTime = FLOAT_METRIC(@"SongPlay Go ShowTime");
	
	// And sounds
	sr_Failed = SOUND(@"SongPlay Failed");
	sr_Cleared = SOUND(@"SongPlay Cleared");
	
	g_pGameState->m_pSteps = [g_pGameState->m_pSong getStepsForDifficulty:g_pGameState->m_nSelectedDifficulty];
	
	// Init the receptor row
	m_pReceptorRow = [[ReceptorRow alloc] init];
	
	// Init the lifebar
	m_pLifeBar = [[LifeBar alloc] initWithRect:mt_LifeBar];
	
	// Init a combometer
	m_pComboMeter = [[ComboMeter alloc] initWithMetrics:@"SongPlay Combo"];
	
	// Init the score counter
	m_pScoreMeter = [[ScoreMeter alloc] initWithMetrics:@"SongPlay Score" forSteps:g_pGameState->m_pSteps];
	
	g_pGameState->m_bPlayingGame = NO;
	
	// Subscribe to messages
	SUBSCRIBE(kLifeBarDrainedMessage);
	
	return self;
}

- (void) dealloc {
	UNSUBSCRIBE_ALL();
	[m_pSound release];

	// Allow news system updates
	[[NewsFetcher sharedInstance] startChecking];	
	
	[super dealloc];
}

- (void) setupForTransition {
	[super setupForTransition];
	
	// Enable joypad
	m_pJoyPad = [[TapMania sharedInstance] enableJoyPad];	
	
	// Trigger song play
	[self playSong];
}

- (void) playSong {	
#ifdef DEBUG 
	[g_pGameState->m_pSteps dump];
#endif	
	
	g_pGameState->m_bAutoPlay = NO;
	g_pGameState->m_nFailType = kFailAtEnd;
	
	g_pGameState->m_bFailed = g_pGameState->m_bGaveUp = NO;
			
	[t_Judgement reset];
	[t_HoldJudgement reset];

	m_pSound = [[TMSound alloc] initWithPath:
				[[[SongsDirectoryCache sharedInstance] getSongsPath] stringByAppendingPathComponent:g_pGameState->m_pSong.m_sMusicFilePath]];
	[[TMSoundEngine sharedInstance] addToQueueWithManualStart:m_pSound];
	
	// Calculate starting offset for music playback
	TMLog(@"Try to get first and last beat");
	double timeOfFirstBeat = [TimingUtil getElapsedTimeFromBeat:[TMNote noteRowToBeat:[g_pGameState->m_pSteps getFirstNoteRow]] inSong:g_pGameState->m_pSong];
	double timeOfLastBeat = [TimingUtil getElapsedTimeFromBeat:[TMNote noteRowToBeat:[g_pGameState->m_pSteps getLastNoteRow]] inSong:g_pGameState->m_pSong];
	
	TMLog(@"first: %f   last: %f", timeOfFirstBeat, timeOfLastBeat);
	TMLog(@"first nr: %d", [g_pGameState->m_pSteps getFirstNoteRow]);
	
	double now = [TimingUtil getCurrentTime];
	m_dScreenEnterTime = now;
	
	if(timeOfFirstBeat <= kMinTimeTillStart){
		g_pGameState->m_dPlayBackStartTime = now + (kMinTimeTillStart - timeOfFirstBeat);
		m_bMusicPlaybackStarted = NO;
	} else {
		g_pGameState->m_dPlayBackStartTime = now;
		[[TMSoundEngine sharedInstance] playMusic];
		m_bMusicPlaybackStarted = YES;
	}

	m_bIsFading = NO;
	m_dPlayBackScheduledEndTime = g_pGameState->m_dPlayBackStartTime + timeOfLastBeat + kTimeTillMusicStop;
	m_dPlayBackScheduledFadeOutTime = m_dPlayBackScheduledEndTime - kFadeOutTime;
	
	g_pGameState->m_bPlayingGame = YES;	
	m_bDrawReady = YES;
	m_bDrawGo = m_bDrawnGo = NO;
	
	m_bDrawFailed = m_bDrawCleared = NO;
	
	// Setup kids to render in right order
	[self pushBackChild:m_pReceptorRow];
	[self pushBackChild:[g_pGameState->m_pSteps retain]];	
	[self pushBackChild:[t_Judgement retain]];
	[self pushBackChild:[t_HoldJudgement retain]];
	[self pushBackChild:m_pComboMeter];
	[self pushBackChild:m_pLifeBar];	
	[self pushBackChild:m_pScoreMeter];
}

// Updates one frame of the gameplay
- (void)update:(float)fDelta {	
	
	if(!g_pGameState->m_bPlayingGame)
		return;
	
	// Calculate current elapsed time
	double currentTime = [TimingUtil getCurrentTime];
	
	// Double check we have something normal as time. this is a workaround
	if(currentTime < 0.0) currentTime = [TimingUtil getCurrentTime];
	
	g_pGameState->m_dElapsedTime = currentTime - g_pGameState->m_dPlayBackStartTime;
	
	if(m_bDrawFailed) {
		double elapsedTime = currentTime - m_dFailedTime;
		if(elapsedTime >= mt_FailedMaxShowTime) {
			
			// request transition		
			[[TapMania sharedInstance] switchToScreen:[SongResultsRenderer class] withMetrics:@"SongResults"];
			g_pGameState->m_bPlayingGame = NO;		
		}
		
		return;
		
	} else if(m_bDrawCleared) {
		double elapsedTime = currentTime - m_dClearedTime;
		if(elapsedTime >= mt_ClearedMaxShowTime) {
			
			// request transition		
			[[TapMania sharedInstance] switchToScreen:[SongResultsRenderer class] withMetrics:@"SongResults"];
			g_pGameState->m_bPlayingGame = NO;							
		}
		
		return;
	}	
	
	// Update all kids
	[super update:fDelta];
	
	// Start music with delay if required
	if(!m_bMusicPlaybackStarted) {
		if(g_pGameState->m_dPlayBackStartTime <= currentTime){
			m_bMusicPlaybackStarted = YES;
			[[TMSoundEngine sharedInstance] playMusic];
		}
	} else if(currentTime >= m_dPlayBackScheduledEndTime || [m_pJoyPad getStateForButton:kJoyButtonExit] 
			  || (g_pGameState->m_bFailed && g_pGameState->m_nFailType == kFailOn)) 
	{
		// Should stop music and stop gameplay now
		[[TMSoundEngine sharedInstance] stopMusic];

		if([m_pJoyPad getStateForButton:kJoyButtonExit])
			g_pGameState->m_bGaveUp = YES;
		
		if(g_pGameState->m_bFailed || g_pGameState->m_bGaveUp) {
			[[TMSoundEngine sharedInstance] playEffect:sr_Failed];
			m_bDrawFailed = YES;
			m_dFailedTime = [TimingUtil getCurrentTime];				

		} else {
			[[TMSoundEngine sharedInstance] playEffect:sr_Cleared];
			m_bDrawCleared = YES;
			m_dClearedTime = [TimingUtil getCurrentTime];				
		}
		
		// Disable the joypad
		[[TapMania sharedInstance] disableJoyPad];
					
		// Drop other flags like ready/go
		m_bDrawGo = m_bDrawReady = m_bDrawnGo = NO;
		return;
		
	} else if(currentTime >= m_dPlayBackScheduledFadeOutTime) {
		if(!m_bIsFading) {
			m_bIsFading = YES;
			[[TMSoundEngine sharedInstance] stopMusicFading:kFadeOutTime];
		}
	}
		
	// Check ready/go sprites
	double elapsedTimeSinceEntrance = currentTime - m_dScreenEnterTime;
	if(elapsedTimeSinceEntrance >= mt_ReadyShowTime) {
		m_bDrawReady = NO;
	}
	
	if(!m_bDrawReady && (!m_bDrawnGo || m_bDrawGo) && elapsedTimeSinceEntrance <= mt_ReadyShowTime+mt_GoShowTime) {
		m_bDrawGo = YES;
		m_bDrawnGo = YES;
	} else {
		m_bDrawGo = NO;
	}
}

// Renders one scene of the gameplay
- (void)render:(float)fDelta {
	CGRect bounds = [TapMania sharedInstance].glView.bounds;
		
	if(!g_pGameState->m_bPlayingGame) return;
	
	// Draw kids
	[super render:fDelta];	
			
	// Draw the pad if requested
	if(cfg_VisPad) {
		glEnable(GL_BLEND);
		
		for(int i=0; i<kNumOfAvailableTracks; i++) {
			Vector* pVec = [[TapMania sharedInstance].joyPad getJoyPadButton:(JPButton)i];
			
			if([m_pJoyPad getStateForButton:(JPButton)i]) {
				[t_FingerTap drawFrame:i atPoint:CGPointMake(pVec.m_fX, pVec.m_fY)];
			}	else {
				[t_FingerTap drawFrame:i+kNumOfAvailableTracks atPoint:CGPointMake(pVec.m_fX, pVec.m_fY)];
			}
		}
		
		glDisable(GL_BLEND);
	}
	
	// Draw the ready/go sprites if necesarry
	if(m_bDrawReady) {
		glEnable(GL_BLEND);
		[t_Ready drawAtPoint:mt_Ready];		
		glDisable(GL_BLEND);		
	} else if(m_bDrawGo) {
		glEnable(GL_BLEND);
		[t_Go drawAtPoint:mt_Go];
		glDisable(GL_BLEND);		
	}
	
	// Check fail status and draw failed/cleared
	if(m_bDrawFailed) {		
		[self fade];
		
		glEnable(GL_BLEND);
		[t_Failed drawAtPoint:mt_Failed];
		glDisable(GL_BLEND);

	} else if(m_bDrawCleared) {
		[self fade];
		
		glEnable(GL_BLEND);
		[t_Cleared drawAtPoint:mt_Cleared];
		glDisable(GL_BLEND);
	}
	
}

/* TMTransitionSupport methods */
- (void) beforeTransition {
	// Save the combo and the score
	g_pGameState->m_nCombo = [m_pComboMeter getMaxCombo];
	g_pGameState->m_nScore = [m_pScoreMeter getScore];
}

/* TMMessageSupport stuff */
-(void) handleMessage:(TMMessage*)message {
	switch (message.messageId) {
		case kLifeBarDrainedMessage:
			TMLog(@"Life is drained! Stop gameplay.");
			if(g_pGameState->m_nFailType == kFailOn || g_pGameState->m_nFailType == kFailAtEnd) {
				g_pGameState->m_bFailed = YES;
			}
			
			break;
	}
}

-(void) fade {
	
	CGRect	rect = [TapMania sharedInstance].glView.bounds;
	GLfloat	vertices[] = {	
		rect.origin.x,							rect.origin.y,							
		rect.origin.x + rect.size.width,		rect.origin.y,							
		rect.origin.x,							rect.origin.y + rect.size.height,		
		rect.origin.x + rect.size.width,		rect.origin.y + rect.size.height 
	};
	
	glColor4f(0, 0, 0, 0.7);
	glDisable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glVertexPointer(2, GL_FLOAT, 0, vertices);	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glDisable(GL_BLEND);
	glEnable(GL_TEXTURE_2D);		
	glColor4f(1, 1, 1, 1);
	TMBindTexture(0);
	
}	

@end
