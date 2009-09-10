//
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

#import "SongResultsRenderer.h"

#import "TMSong.h"
#import "TMTrack.h"
#import "TMSongOptions.h"
#import "TMChangeSegment.h"

#import "ReceptorRow.h"
#import "LifeBar.h"

#import "SettingsEngine.h"
#import "ThemeManager.h"
#import "TapMania.h"
#import "EAGLView.h"
#import "JoyPad.h"

#import "TapNote.h"
#import "HoldNote.h"
#import "HoldJudgement.h"
#import "Judgement.h"

#import <math.h>

@implementation SongPlayRenderer

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	// Cache metrics
	for(int i=0; i<kNumOfAvailableTracks; ++i) {
		mt_TapNotes[i] =					RECT_METRIC(([NSString stringWithFormat:@"SongPlay TapNote %d", i]));
		mt_TapNoteRotations[i] =			FLOAT_METRIC(([NSString stringWithFormat:@"SongPlay TapNote Rotation %d", i]));		
		mt_HalfOfArrowHeight[i] =			mt_TapNotes[i].size.height/2;
		
		mt_Receptors[i]	=					RECT_METRIC(([NSString stringWithFormat:@"SongPlay ReceptorRow %d", i]));
	}
	
	mt_Judgement =							POINT_METRIC(@"SongPlay Judgement");
	mt_JudgementMaxShowTime =				FLOAT_METRIC(@"SongPlay Judgement MaxShowTime");
	
	mt_HoldCap =							SIZE_METRIC(@"SongPlay HoldNote Cap");
	mt_HoldBody =							SIZE_METRIC(@"SongPlay HoldNote Body");
	mt_LifeBar =							RECT_METRIC(@"SongPlay LifeBar");
	
	cfg_VisPad =							CFG_BOOL(@"vispad");

	// Cache graphics
	t_TapNote = (TapNote*)SKIN_TEXTURE(@"DownTapNote");
	t_HoldNoteActive = (HoldNote*)SKIN_TEXTURE(@"HoldBody DownActive");
	t_HoldNoteInactive = (HoldNote*)SKIN_TEXTURE(@"HoldBody DownInactive");
	
	t_HoldBottomCapActive = SKIN_TEXTURE(@"HoldBody BottomCapActive");
	t_HoldBottomCapInactive = SKIN_TEXTURE(@"HoldBody BottomCapInactive");
	
	t_Judgement = (Judgement*)TEXTURE(@"SongPlay Judgement");
	t_HoldJudgement = (HoldJudgement*)TEXTURE(@"SongPlay HoldJudgement");	
	
	t_FingerTap = TEXTURE(@"Common FingerTap");
	t_BG = TEXTURE(@"SongPlay Background");
	t_Failed = TEXTURE(@"SongPlay Failed");
	t_Cleared = TEXTURE(@"SongPlay Cleared");
	
	t_Ready = TEXTURE(@"SongPlay Ready");
	t_Go = TEXTURE(@"SongPlay Go");
	
	// And sounds
	sr_Failed = SOUND(@"SongPlay Failed");
	sr_Cleared = SOUND(@"SongPlay Cleared");
		
	// Init the receptor row
	m_pReceptorRow = [[ReceptorRow alloc] init];
	[self pushBackChild:m_pReceptorRow];
	
	// Init the lifebar
	m_pLifeBar = [[LifeBar alloc] initWithRect:mt_LifeBar];
	[self pushBackChild:m_pLifeBar];

	m_bPlayingGame = NO;
	
	return self;
}

- (void) dealloc {
	[m_pSound release];
		
	[super dealloc];
}

- (void) playSong:(TMSong*) song withOptions:(TMSongOptions*) options {
	m_pSong = [song retain];
	m_pSteps = [m_pSong getStepsForDifficulty:options.m_nDifficulty];
	
#ifdef DEBUG 
	[m_pSteps dump];
#endif	
	
	m_bAutoPlay = YES;
	
	TMLog(@"Steps recieved by songplayrenderer");
	
	m_bFailed = NO;
	m_dSpeedModValue = [TMSongOptions speedModToValue:options.m_nSpeedMod];
	
	int i;
	
	// Drop track positions to first elements
	for(i=0; i<kNumOfAvailableTracks; i++) {
		m_nTrackPos[i] = 0;
	}
	
	[t_Judgement reset];
	[t_HoldJudgement reset];

	m_pSound = [[TMSound alloc] initWithPath:
				[[[SongsDirectoryCache sharedInstance] getSongsPath] stringByAppendingPathComponent:m_pSong.m_sMusicFilePath]];
	[[TMSoundEngine sharedInstance] addToQueueWithManualStart:m_pSound];
	
	// Calculate starting offset for music playback
	TMLog(@"Try to get first and last beat");
	double timeOfFirstBeat = [TimingUtil getElapsedTimeFromBeat:[TMNote noteRowToBeat:[m_pSteps getFirstNoteRow]] inSong:m_pSong];
	double timeOfLastBeat = [TimingUtil getElapsedTimeFromBeat:[TMNote noteRowToBeat:[m_pSteps getLastNoteRow]] inSong:m_pSong];
	TMLog(@"Success...");
	
	TMLog(@"first: %f   last: %f", timeOfFirstBeat, timeOfLastBeat);
	TMLog(@"first nr: %d", [m_pSteps getFirstNoteRow]);
	
	double now = [TimingUtil getCurrentTime];
	m_dScreenEnterTime = now;
	
	if(timeOfFirstBeat <= kMinTimeTillStart){
		m_dPlayBackStartTime = now + (kMinTimeTillStart - timeOfFirstBeat);
		m_bMusicPlaybackStarted = NO;
	} else {
		m_dPlayBackStartTime = now;
		[[TMSoundEngine sharedInstance] playMusic];
		m_bMusicPlaybackStarted = YES;
	}

	m_bIsFading = NO;
	m_dPlayBackScheduledEndTime = m_dPlayBackStartTime + timeOfLastBeat + kTimeTillMusicStop;
	m_dPlayBackScheduledFadeOutTime = m_dPlayBackScheduledEndTime - kFadeOutTime;

	// Most likely we must start animating on a calculated time.. FIXME
	[t_TapNote startAnimation];
	
	// Enable joypad
	m_pJoyPad = [[TapMania sharedInstance] enableJoyPad];

	m_bPlayingGame = YES;	
	m_bDrawReady = YES;
	m_bDrawGo = NO;
}

// Updates one frame of the gameplay
- (void)update:(float)fDelta {	
	[super update:fDelta];
	
	if(!m_bPlayingGame) return;
	
	// Calculate current elapsed time
	double currentTime = [TimingUtil getCurrentTime];
	double elapsedTime = currentTime - m_dPlayBackStartTime;
	
	// Start music with delay if required
	if(!m_bMusicPlaybackStarted) {
		if(m_dPlayBackStartTime <= currentTime){
			m_bMusicPlaybackStarted = YES;
			[[TMSoundEngine sharedInstance] playMusic];
		}
	} else if(currentTime >= m_dPlayBackScheduledEndTime || [m_pJoyPad getStateForButton:kJoyButtonExit] || m_bFailed) {
		// Should stop music and stop gameplay now
		// TODO: some fadeout would be better
		[[TMSoundEngine sharedInstance] stopMusic];

		// Stop animating the arrows
		[t_TapNote stopAnimation];
	
		// Disable the joypad
		[[TapMania sharedInstance] disableJoyPad];
	
		// request transition
		SongResultsRenderer *srScreen = [[SongResultsRenderer alloc] initWithSong:m_pSong withSteps:m_pSteps];
		
		[[TapMania sharedInstance] switchToScreen:srScreen];
		m_bPlayingGame = NO;
	} else if(currentTime >= m_dPlayBackScheduledFadeOutTime) {
		if(!m_bIsFading) {
			m_bIsFading = YES;
			[[TMSoundEngine sharedInstance] stopMusicFading:kFadeOutTime];
		}
	}
		
	
	float currentBeat, currentBps;
	BOOL hasFreeze;
	
	[TimingUtil getBeatAndBPSFromElapsedTime:elapsedTime beatOut:&currentBeat bpsOut:&currentBps freezeOut:&hasFreeze inSong:m_pSong]; 
	
	// Calculate animation of the tap notes. The speed of the animation is actually one frame per beat
	[t_TapNote setM_fFrameTime:[TimingUtil getTimeInBeatForBPS:currentBps]];
	[t_TapNote update:fDelta];
	
	// Update judgement state
	[t_Judgement update:fDelta];
	[t_HoldJudgement update:fDelta];
	
	// If freeze - stop animating the notes but still check for hits etc.
	if(hasFreeze) {
		[t_TapNote pauseAnimation];
	} else {
		[t_TapNote continueAnimation];
	}
	
	double searchHitFromTime = elapsedTime - 0.1f;
	double searchHitTillTime = elapsedTime + 0.1f;
	int i;
	
	// For every track
	for(i=0; i<kNumOfAvailableTracks; i++) {
		// Search in this track for items starting at index:
		int startIndex = m_nTrackPos[i];
		int j;
		
		// This will hold the Y coordinate of the previous note in this track
		float lastNoteYPosition = mt_Receptors[i].origin.y;
		
		TMNote* prevNote = nil;
		
		double lastHitTime = [m_pJoyPad getTouchTimeForButton:(JPButton)i] - m_dPlayBackStartTime;		
		BOOL testHit = NO;

		// Check for hit?
		if(lastHitTime >= searchHitFromTime && lastHitTime <= searchHitTillTime) {
			testHit = YES;
		}
		 
		// For all interesting notes in the track
		for(j=startIndex; j<[m_pSteps getNotesCountForTrack:i] ; ++j) {
			TMNote* note = [m_pSteps getNote:j fromTrack:i];
			
			// We are not handling empty notes though
			if(note.m_nType == kNoteType_Empty)
				continue;
			
			// Get beats out of noteRows
			float beat = [TMNote noteRowToBeat: note.m_nStartNoteRow];
			float tillBeat = note.m_nStopNoteRow == -1 ? -1.0f : [TMNote noteRowToBeat: note.m_nStopNoteRow];
			
			float noteBps = [TimingUtil getBpsAtBeat:beat inSong:m_pSong];
			
			float noteYPosition = lastNoteYPosition;
			float holdBottomCapYPosition = 0.0f;
			
			int lastNoteRow = prevNote ? prevNote.m_nStartNoteRow : [TMNote beatToNoteRow:currentBeat];
			int nextBpmChangeNoteRow = [TimingUtil getNextBpmChangeFromBeat:[TMNote noteRowToBeat:lastNoteRow] inSong:m_pSong];
			
			double noteTime = [TimingUtil getElapsedTimeFromBeat:beat inSong:m_pSong];
			
			if(m_bAutoPlay) {
				if(fabsf(noteTime - elapsedTime) <= 0.03f) {
					testHit = YES;
					lastHitTime = elapsedTime;
				}
			}
			
			// Now for every bpmchange we must apply all bpmchange related offsets
			while (nextBpmChangeNoteRow != -1 && nextBpmChangeNoteRow < note.m_nStartNoteRow) {
				float tBps = [TimingUtil getBpsAtBeat:[TMNote noteRowToBeat:nextBpmChangeNoteRow-1] inSong:m_pSong];
				
				noteYPosition -= (nextBpmChangeNoteRow-lastNoteRow)*[TimingUtil getPixelsPerNoteRowForBPS:tBps andSpeedMod:m_dSpeedModValue];
				lastNoteRow = nextBpmChangeNoteRow;
				nextBpmChangeNoteRow = [TimingUtil getNextBpmChangeFromBeat:[TMNote noteRowToBeat:nextBpmChangeNoteRow] inSong:m_pSong];
			}
			
			// Calculate for last segment
			noteYPosition -= (note.m_nStartNoteRow-lastNoteRow)*[TimingUtil getPixelsPerNoteRowForBPS:noteBps andSpeedMod:m_dSpeedModValue];
			note.m_fStartYPosition = noteYPosition;
			
			/* We must also calculate the Y position of the bottom cap of the hold if we handle a hold note */
			if(note.m_nType == kNoteType_HoldHead) {
				// If we hit (was ever holding) the note now we must fix it on the receptor base
				if(note.m_bIsHit) {
					note.m_fStartYPosition = mt_Receptors[i].origin.y;
				}
				
				// Start from the calculated note head position
				holdBottomCapYPosition = noteYPosition;
				lastNoteRow = note.m_nStartNoteRow;
				
				nextBpmChangeNoteRow = [TimingUtil getNextBpmChangeFromBeat:[TMNote noteRowToBeat:lastNoteRow] inSong:m_pSong];
				
				// Now for every bpmchange we must apply all bpmchange related offsets
				while (nextBpmChangeNoteRow != -1 && nextBpmChangeNoteRow < note.m_nStopNoteRow) {
					float tBps = [TimingUtil getBpsAtBeat:[TMNote noteRowToBeat:nextBpmChangeNoteRow-1] inSong:m_pSong];
					
					holdBottomCapYPosition -= (nextBpmChangeNoteRow-lastNoteRow)*[TimingUtil getPixelsPerNoteRowForBPS:tBps andSpeedMod:m_dSpeedModValue];
					lastNoteRow = nextBpmChangeNoteRow;
					nextBpmChangeNoteRow = [TimingUtil getNextBpmChangeFromBeat:[TMNote noteRowToBeat:nextBpmChangeNoteRow] inSong:m_pSong];
				}
				
				// Calculate for last segment of the hold body
				float capBps = [TimingUtil getBpsAtBeat:tillBeat inSong:m_pSong];
				holdBottomCapYPosition -= (note.m_nStopNoteRow-lastNoteRow)*[TimingUtil getPixelsPerNoteRowForBPS:capBps andSpeedMod:m_dSpeedModValue];			
				
				note.m_fStopYPosition = holdBottomCapYPosition;
			}
			
			// Check whether we already missed a note (hold head too)
			if(!note.m_bIsLost && !note.m_bIsHit && (elapsedTime-noteTime)>=0.1f) {
				[m_pSteps markAllNotesLostFromRow:note.m_nStartNoteRow];		
				[note score:kNoteScore_MissL];	// Only one of the notes get the scoring set

				[t_Judgement setCurrentJudgement:kJudgementMiss andTimingFlag:kTimingFlagLate];
				[m_pLifeBar updateBy:[TimingUtil getLifebarChangeByNoteScore:kNoteScore_MissL]];				
				
				// Extra judgement for hold notes..
				// TODO: all hold notes which are not held now should show NG. not only one.
				if(note.m_nType == kNoteType_HoldHead) {
					[m_pLifeBar updateBy:-0.080];	// NG judgement
					[t_HoldJudgement setCurrentHoldJudgement:kHoldJudgementNG forTrack:(TMAvailableTracks)i];		
					[note markHoldLost];
				}
			}
			
			// Check whether this note is already out of scope
			if(note.m_nType != kNoteType_HoldHead && noteYPosition >= 480.0f) {
				++m_nTrackPos[i];				
				continue; // Skip this note
			}

			// Now the same for hold notes
			if(note.m_nType == kNoteType_HoldHead) {
				if(note.m_bIsHit && holdBottomCapYPosition >= mt_Receptors[i].origin.y) {
					if(note.m_bIsHeld) {
						[m_pLifeBar updateBy:0.008];
						[t_HoldJudgement setCurrentHoldJudgement:kHoldJudgementOK forTrack:(TMAvailableTracks)i];
					}
					
					++m_nTrackPos[i];
					continue; // Skip this hold already
				} else if (!note.m_bIsHit && holdBottomCapYPosition >= 480.0f) {
					// Let the hold go till the end of the screen. The lifebar and the NG graphic is done already when the hold was lost
					++m_nTrackPos[i];
					continue; // Skip
				}				
			}
			
			// If the Y position is at the floor - jump to next track
			if(note.m_fStartYPosition <= -mt_TapNotes[i].size.height){
				break; // Start another track coz this note is out of screen
			}				
			
			// Check old hit first
			if(testHit && note.m_bIsHit){
				// This note was hit already (maybe using the same tap as we still hold)
				if(note.m_dHitTime == lastHitTime) {
					// Bingo! prevent further notes in this track from being hit
					testHit = NO;
				} 
			}
			 
			// If we are at a hold arrow we must check it anyway
			if(note.m_nType == kNoteType_HoldHead) {
				double lastReleaseTime = [m_pJoyPad getReleaseTimeForButton:(JPButton)i] - m_dPlayBackStartTime;
				
				if(m_bAutoPlay) {
					lastReleaseTime = lastHitTime-0.01f;
				}
				
				if(note.m_bIsHit && !note.m_bIsHoldLost && !note.m_bIsHolding) {
					// This means we released the hold but we still can catch it again
					if(fabsf(elapsedTime - note.m_dLastHoldReleaseTime) >= 0.4f) {
						[note markHoldLost];
						[m_pLifeBar updateBy:-0.080];	// NG judgement
						[t_HoldJudgement setCurrentHoldJudgement:kHoldJudgementNG forTrack:(TMAvailableTracks)i];					
					}
					
					// But maybe we have touched it again before it was marked as lost totally?
					if(!note.m_bIsHoldLost && note.m_dLastHoldReleaseTime < lastHitTime) {
						[note startHolding:lastHitTime];
					}
				} else if(note.m_bIsHit && !note.m_bIsHoldLost && note.m_bIsHolding) {				
					if(lastReleaseTime >= lastHitTime) {						
						[note stopHolding:lastReleaseTime];
					}
				} 
			}
			
			// Check hit
			if(testHit && !note.m_bIsLost && !note.m_bIsHit){
				if(noteTime >= searchHitFromTime && noteTime <= searchHitTillTime) {
				
					// Mark note as hit
					[note hit:lastHitTime];
					testHit = NO; // Don't want to test hit on other notes on the track in this run
					
					if(note.m_nType == kNoteType_HoldHead) {
						[note startHolding:lastHitTime];
					}
					
					// Check whether other tracks has any notes which are not hit yet and are on the same noterow
					double timesOfHit[kNumOfAvailableTracks];
					BOOL allNotesHit = [m_pSteps checkAllNotesHitFromRow:note.m_nStartNoteRow time1Out:&timesOfHit[0] time2Out:&timesOfHit[1] time3Out:&timesOfHit[2] time4Out:&timesOfHit[3]];
					
					// After the previous check we should know whether all the notes on the noterow are already hit
					if(allNotesHit == YES) {					
					
						// Get the worse scoring of all hit notes
						double worseDelta = 0.0f;
						TMTimingFlag timingFlag;
						
						int tr = 0;
						for(; tr<kNumOfAvailableTracks; ++tr){
							if(timesOfHit[tr] != 0.0f) {
								double timing = noteTime-timesOfHit[tr];
								double thisDelta = fabs(timing);

								if(thisDelta > worseDelta) {
									worseDelta = thisDelta;
									timingFlag = timing<0?kTimingFlagEarly:kTimingFlagLate;
								}
							}
						}
						
						TMNoteScore noteScore = [TimingUtil getNoteScoreByDelta:worseDelta andTimingFlag:timingFlag];
						TMJudgement noteJudgement = [TimingUtil getJudgementByScore:noteScore];
						
						// Set the score to the note (group of notes. only one will count anyway)
						[note score:noteScore];
						
						[t_Judgement setCurrentJudgement:noteJudgement andTimingFlag:timingFlag];
						[m_pLifeBar updateBy:[TimingUtil getLifebarChangeByNoteScore:noteScore]];
						
						// Explode all hit tracks
						for(tr=0; tr<kNumOfAvailableTracks; ++tr){
							if(timesOfHit[tr] != 0.0f) {							
								if(noteJudgement == kJudgementW1) {
									[m_pReceptorRow explodeBright:(TMAvailableTracks)tr];
								} else {
									[m_pReceptorRow explodeDim:(TMAvailableTracks)tr];
								}
							}
						}
					}
				}
			}
				
			prevNote = note;
			lastNoteYPosition = noteYPosition;
		}
	}
	
	// Check lifebar
	if([m_pLifeBar getCurrentValue] < kMinLifeToKeepAlive) {
		TMLog(@"Life is drained! Stop gameplay.");
		m_bFailed = YES;
	}
	
	// Check ready/go sprites
	double elapsedTimeSinceEntrance = currentTime - m_dScreenEnterTime;
	if(elapsedTimeSinceEntrance >= kReadySpriteTime) {
		m_bDrawReady = NO;
	}
	
	if(!m_bDrawReady && elapsedTimeSinceEntrance <= kReadySpriteTime+kGoSpriteTime) {
		m_bDrawGo = YES;
	} else {
		m_bDrawGo = NO;
	}
}

// Renders one scene of the gameplay
- (void)render:(float)fDelta {
	CGRect bounds = [TapMania sharedInstance].glView.bounds;
	
	[t_BG drawInRect:bounds];
	
	if(!m_bPlayingGame) return;

	// Draw kids
	[super render:fDelta];	
	
	// For every track
	for(int i=0; i<kNumOfAvailableTracks; i++) {
		
		// Search in this track for items starting at index:
		int startIndex = m_nTrackPos[i];
		int j;
	
		// For all interesting notes in the track
		for(j=startIndex; j<[m_pSteps getNotesCountForTrack:i] ; j++) {
			TMNote* note = [m_pSteps getNote:j fromTrack:i];
			
			// We are not handling empty notes though
			if(note.m_nType == kNoteType_Empty)
				continue;
			
			// We will draw the note only if it wasn't hit yet
			if(note.m_nType == kNoteType_HoldHead || !note.m_bIsHit) {
				if(note.m_fStartYPosition <= -mt_TapNotes[i].size.height) {
					break; // Start another track coz this note is out of screen
				}
				
				// If note is a holdnote
				if(note.m_nType == kNoteType_HoldHead) {			
					// Calculate body length
					float bodyTopY = note.m_fStartYPosition + mt_HalfOfArrowHeight[i]; // Plus half of the tap note so that it will be overlapping
					float bodyBottomY = note.m_fStopYPosition + mt_HalfOfArrowHeight[i]; // Make space for bottom cap
					
					// Determine the track X position now
					float holdX = mt_TapNotes[i].origin.x;
					
					// Calculate the height of the hold's body
					float totalBodyHeight = bodyTopY - bodyBottomY;
					float offset = bodyBottomY;
					
					// Draw every piece separately
					do{
						float sizeOfPiece = totalBodyHeight > mt_HoldBody.height ? mt_HoldBody.height : totalBodyHeight;
						
						// Don't draw if we are out of screen
						if(offset+sizeOfPiece > 0.0f) {					
							if(note.m_bIsHolding) {
								[t_HoldNoteActive drawBodyPieceWithSize:sizeOfPiece atPoint:CGPointMake(holdX, offset)];
							} else {
								[t_HoldNoteInactive drawBodyPieceWithSize:sizeOfPiece atPoint:CGPointMake(holdX, offset)];
							}
						}
						
						totalBodyHeight -= mt_HoldBody.height;
						offset += mt_HoldBody.height;
					} while(totalBodyHeight > 0.0f);					
					
					// determine the position of the cap and draw it if needed
					if(bodyBottomY > 0.0f) {
						// Ok. must draw the cap
						glEnable(GL_BLEND);

						if(note.m_bIsHolding) {
							[t_HoldBottomCapActive drawInRect:CGRectMake(holdX, bodyBottomY-(mt_HoldCap.height-1), mt_HoldCap.width, mt_HoldCap.height)];
						} else {
							[t_HoldBottomCapInactive drawInRect:CGRectMake(holdX, bodyBottomY-(mt_HoldCap.height-1), mt_HoldCap.width, mt_HoldCap.height)];
						}
						
						glDisable(GL_BLEND);
					}
				}
				
				CGRect arrowRect = CGRectMake(mt_TapNotes[i].origin.x, note.m_fStartYPosition, mt_TapNotes[i].size.width, mt_TapNotes[i].size.height);
				if(note.m_nType == kNoteType_HoldHead) {
					if(note.m_bIsHolding) {
						[t_TapNote drawHoldTapNoteHolding:note.m_nBeatType direction:(TMNoteDirection)i inRect:arrowRect];
					} else { 
						[t_TapNote drawHoldTapNoteReleased:note.m_nBeatType direction:(TMNoteDirection)i inRect:arrowRect];	
					}
				} else {
					[t_TapNote drawTapNote:note.m_nBeatType direction:(TMNoteDirection)i inRect:arrowRect];
				}			
			}
		}
	}
			
	// Draw the judgement
	[t_Judgement render:fDelta];
	[t_HoldJudgement render:fDelta];
	
	// Draw the pad if requested
	if(cfg_VisPad) {
		glEnable(GL_BLEND);
		
		for(int i=0; i<kNumOfAvailableTracks; i++) {
			Vector* pVec = [[TapMania sharedInstance].joyPad getJoyPadButton:(JPButton)i];
			[t_FingerTap drawAtPoint:CGPointMake(pVec.m_fX, pVec.m_fY)];				
		}
		
		glDisable(GL_BLEND);
	}
	
	// Draw the ready/go sprites if necesarry
	if(m_bDrawReady) {
		glEnable(GL_BLEND);
		[t_Ready drawAtPoint:CGPointMake(160, 240)];		
		glDisable(GL_BLEND);		
	} else if(m_bDrawGo) {
		glEnable(GL_BLEND);
		[t_Go drawAtPoint:CGPointMake(160, 240)];
		glDisable(GL_BLEND);		
	}
}

/* TMTransitionSupport methods */
- (void) beforeTransition {
	// Before we start the transition to the results screen.
	// Good place to play some sounds and show some effects
	CGRect bounds = [TapMania sharedInstance].glView.bounds;
	[t_BG drawInRect:bounds];
	
	if(m_bFailed) {
		[[TMSoundEngine sharedInstance] playEffect:sr_Failed];

		glEnable(GL_BLEND);
		[t_Failed drawAtPoint:CGPointMake(160, 240)];
		glDisable(GL_BLEND);
	} else {
		[[TMSoundEngine sharedInstance] playEffect:sr_Cleared];
		
		glEnable(GL_BLEND);
		[t_Cleared drawAtPoint:CGPointMake(160, 240)];
		glDisable(GL_BLEND);
	}
	
	[[[TapMania sharedInstance] glView] swapBuffers];		
	[NSThread sleepForTimeInterval:1.5f];		
}

@end
