//
//  SongPlayRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "SongPlayRenderer.h"
#import "TapManiaAppDelegate.h"
#import "SoundEffectsHolder.h"
#import "SoundEngine.h"
#import "TimingUtil.h"
#import "SongsDirectoryCache.h"
#import "DWIParser.h"

#import "SongResultsRenderer.h"

#import "TMSong.h"
#import "TMTrack.h"
#import "TMSongOptions.h"
#import "TMChangeSegment.h"

#import "ReceptorRow.h"
#import "LifeBar.h"

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

// Theme stuff
Judgement*	t_Judgement;
HoldJudgement* t_HoldJudgement;

// Noteskin stuff
TapNote* t_TapNote;
HoldNote* t_HoldNoteInactive, *t_HoldNoteActive;
Texture2D* t_HoldBottomCapActive, *t_HoldBottomCapInactive;
Texture2D* t_BG;

int mt_ReceptorRowY;
int mt_LifeBarX, mt_LifeBarY, mt_LifeBarWidth, mt_LifeBarHeight;
int mt_ArrowLeftX,	mt_ArrowDownX, mt_ArrowUpX, mt_ArrowRightX;
int mt_ArrowWidth, mt_ArrowHeight;
int mt_HoldCapWidth, mt_HoldCapHeight;
float mt_HoldBodyPieceHeight, mt_HalfOfArrowHeight;

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	// Cache metrics	
	mt_ReceptorRowY =	[[ThemeManager sharedInstance] intMetric:@"SongPlay ReceptorRow Y"];
	mt_LifeBarX =		[[ThemeManager sharedInstance] intMetric:@"SongPlay LifeBar X"];
	mt_LifeBarY =		[[ThemeManager sharedInstance] intMetric:@"SongPlay LifeBar Y"];
	mt_LifeBarWidth =	[[ThemeManager sharedInstance] intMetric:@"SongPlay LifeBar Width"];
	mt_LifeBarHeight =	[[ThemeManager sharedInstance] intMetric:@"SongPlay LifeBar Height"];
	
	mt_ArrowLeftX =	[[ThemeManager sharedInstance] intMetric:@"SongPlay TapNote LeftX"];
	mt_ArrowDownX =	[[ThemeManager sharedInstance] intMetric:@"SongPlay TapNote DownX"];
	mt_ArrowUpX =		[[ThemeManager sharedInstance] intMetric:@"SongPlay TapNote UpX"];
	mt_ArrowRightX =	[[ThemeManager sharedInstance] intMetric:@"SongPlay TapNote RightX"];
	mt_ArrowWidth =	[[ThemeManager sharedInstance] intMetric:@"SongPlay TapNote Width"];
	mt_ArrowHeight = [[ThemeManager sharedInstance] intMetric:@"SongPlay TapNote Height"];
	
	mt_HoldCapWidth = [[ThemeManager sharedInstance] intMetric:@"SongPlay HoldNote CapWidth"];	
	mt_HoldCapHeight = [[ThemeManager sharedInstance] intMetric:@"SongPlay HoldNote CapHeight"];	
	mt_HoldBodyPieceHeight = [[ThemeManager sharedInstance] floatMetric:@"SongPlay HoldNote BodyPieceHeight"];	
	
	mt_HalfOfArrowHeight = mt_ArrowHeight / 2.0f;
	
	// Cache graphics
	t_TapNote = (TapNote*)[[ThemeManager sharedInstance] skinTexture:@"DownTapNote"];
	t_HoldNoteActive = (HoldNote*)[[ThemeManager sharedInstance] skinTexture:@"HoldBody DownActive"];
	t_HoldNoteInactive = (HoldNote*)[[ThemeManager sharedInstance] skinTexture:@"HoldBody DownInactive"];
	
	t_HoldBottomCapActive = [[ThemeManager sharedInstance] skinTexture:@"HoldBody BottomCapActive"];
	t_HoldBottomCapInactive = [[ThemeManager sharedInstance] skinTexture:@"HoldBody BottomCapInactive"];
	
	t_Judgement = (Judgement*)[[ThemeManager sharedInstance] texture:@"SongPlay Judgement"];
	t_HoldJudgement = (HoldJudgement*)[[ThemeManager sharedInstance] texture:@"SongPlay HoldJudgement"];	
	
	// FIXME: hardcode!
	t_BG = [[ThemeManager sharedInstance] texture:@"SongPlay BackgroundIndex"];
	
	// Init the receptor row
	m_pReceptorRow = [[ReceptorRow alloc] init];
	
	// Init the lifebar
	m_pLifeBar = [[LifeBar alloc] initWithRect:CGRectMake(mt_LifeBarX, mt_LifeBarY, mt_LifeBarWidth, mt_LifeBarHeight)];

	m_bPlayingGame = NO;
	
	return self;
}


- (void) dealloc {
	[m_pLifeBar release];
	[m_pReceptorRow release];
		
	[super dealloc];
}

- (void) playSong:(TMSong*) song withOptions:(TMSongOptions*) options {
	m_pSong = [song retain];
	m_pSteps = [m_pSong getStepsForDifficulty:options.m_nDifficulty];

	TMLog(@"Steps recieved by songplayrenderer");
	
	m_dSpeedModValue = [TMSongOptions speedModToValue:options.m_nSpeedMod];
	
	int i;
	
	// Drop track positions to first elements
	for(i=0; i<kNumOfAvailableTracks; i++) {
		m_nTrackPos[i] = 0;
	}
	
	SoundEngine_LoadBackgroundMusicTrack([[[[SongsDirectoryCache sharedInstance] getSongsPath] stringByAppendingPathComponent:m_pSong.m_sMusicFilePath] UTF8String], YES, YES);	
	
	// Calculate starting offset for music playback
	double now = [TimingUtil getCurrentTime];
	
	TMLog(@"Try to get first and last beat");
	double timeOfFirstBeat = [TimingUtil getElapsedTimeFromBeat:[TMNote noteRowToBeat:[m_pSteps getFirstNoteRow]] inSong:m_pSong];
	double timeOfLastBeat = [TimingUtil getElapsedTimeFromBeat:[TMNote noteRowToBeat:[m_pSteps getLastNoteRow]] inSong:m_pSong];
	TMLog(@"Success...");
	
	TMLog(@"first: %f   last: %f", timeOfFirstBeat, timeOfLastBeat);
	TMLog(@"first nr: %d", [m_pSteps getFirstNoteRow]);
	
	if(timeOfFirstBeat <= kMinTimeTillStart){
		m_dPlayBackStartTime = now + kMinTimeTillStart;
		m_bMusicPlaybackStarted = NO;
	} else {	
		m_dPlayBackStartTime = now;
		m_bMusicPlaybackStarted = YES;
		SoundEngine_StartBackgroundMusic();
	}

	m_dPlayBackScheduledEndTime = m_dPlayBackStartTime + timeOfLastBeat + kTimeTillMusicStop;

	// Most likely we must start animating on a calculated time.. FIXME
	[t_TapNote startAnimation];
	
	// Enable joypad
	m_pJoyPad = [[TapMania sharedInstance] enableJoyPad];

	m_bPlayingGame = YES;	
}

// Updates one frame of the gameplay
- (void)update:(float)fDelta {	
	if(!m_bPlayingGame) return;
	
	// Calculate current elapsed time
	double currentTime = [TimingUtil getCurrentTime];
	double elapsedTime = currentTime - m_dPlayBackStartTime;
	
	// Start music with delay if required
	if(!m_bMusicPlaybackStarted) {
		if(m_dPlayBackStartTime <= currentTime){
			m_bMusicPlaybackStarted = YES;
			SoundEngine_StartBackgroundMusic();
		}
	} else if(currentTime >= m_dPlayBackScheduledEndTime || [m_pJoyPad getStateForButton:kJoyButtonExit]) {
		// Should stop music and stop gameplay now
		// TODO: some fadeout would be better
		SoundEngine_StopBackgroundMusic(NO);
		SoundEngine_UnloadBackgroundMusicTrack();
		
		// Stop animating the arrows
		[t_TapNote stopAnimation];
	
		// Disable the joypad
		[[TapMania sharedInstance] disableJoyPad];
	
		// request transition
		SongResultsRenderer *srScreen = [[SongResultsRenderer alloc] initWithSong:m_pSong withSteps:m_pSteps];
		
		[[TapMania sharedInstance] switchToScreen:srScreen];
		m_bPlayingGame = NO;
	}	
	
	float currentBeat, currentBps;
	BOOL hasFreeze;
	
	[TimingUtil getBeatAndBPSFromElapsedTime:elapsedTime beatOut:&currentBeat bpsOut:&currentBps freezeOut:&hasFreeze inSong:m_pSong]; 
	
	// Calculate animation of the tap notes. The speed of the animation is actually one frame per beat
	[t_TapNote setM_fFrameTime:[TimingUtil getTimeInBeatForBPS:currentBps]];
	[t_TapNote update:fDelta];

	// Update receptor row animations
	[m_pReceptorRow update:fDelta];
	
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
		float lastNoteYPosition = mt_ReceptorRowY;
		
		TMNote* prevNote = nil;
		
		double lastHitTime = [m_pJoyPad getTouchTimeForButton:i] - m_dPlayBackStartTime;
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
					note.m_fStartYPosition = mt_ReceptorRowY;
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
					[m_pLifeBar updateBy:-0.05];	// NG judgement
					[t_HoldJudgement setCurrentHoldJudgement:kHoldJudgementNG forTrack:i];						
				}
			}
			
			// Check whether this note is already out of scope
			if(note.m_nType != kNoteType_HoldHead && noteYPosition >= 480.0f) {
				++m_nTrackPos[i];				
				continue; // Skip this note
			}

			// Now the same for hold notes
			if(note.m_nType == kNoteType_HoldHead) {
				if(note.m_bIsHit && holdBottomCapYPosition >= mt_ReceptorRowY) {
					// We could loose the hold till here so we didn't do any life bar actions neither did we show OK yet.				
					[m_pLifeBar updateBy:0.05];
					[t_HoldJudgement setCurrentHoldJudgement:kHoldJudgementOK forTrack:i];
					
					++m_nTrackPos[i];
					continue; // Skip this hold already
				} else if (!note.m_bIsHit && holdBottomCapYPosition >= 480.0f) {
					// Let the hold go till the end of the screen. The lifebar and the NG graphic is done already when the hold was lost
					++m_nTrackPos[i];
					continue; // Skip
				}				
			}
			
			// If the Y position is at the floor - jump to next track
			if(note.m_fStartYPosition <= -mt_ArrowHeight){
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
				double lastReleaseTime = [m_pJoyPad getReleaseTimeForButton:i] - m_dPlayBackStartTime;
				
				if(note.m_bIsHit && !note.m_bIsHoldLost && !note.m_bIsHolding) {
					// This means we released the hold but we still can catch it again
					if(fabsf(elapsedTime - note.m_dLastHoldReleaseTime) >= 0.8f) {
						[note markHoldLost];
						[m_pLifeBar updateBy:-0.05];	// NG judgement
						[t_HoldJudgement setCurrentHoldJudgement:kHoldJudgementNG forTrack:i];					
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
								[m_pReceptorRow explodeBright:tr];
							}
						}
					}
				}
			}
				
			prevNote = note;
			lastNoteYPosition = noteYPosition;
		}
	}
}

// Renders one scene of the gameplay
- (void)render:(float)fDelta {
	CGRect bounds = [TapMania sharedInstance].glView.bounds;
	
	[t_BG drawInRect:bounds];
		
	if(!m_bPlayingGame) return;

	// Draw the receptor row
	[m_pReceptorRow render:fDelta];
		
	int i;
	
	// For every track
	for(i=0; i<kNumOfAvailableTracks; i++) {
		
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
				if(note.m_fStartYPosition <= -mt_ArrowHeight) {
					break; // Start another track coz this note is out of screen
				}
				
				// If note is a holdnote
				if(note.m_nType == kNoteType_HoldHead) {			
					// Calculate body length
					float bodyTopY = note.m_fStartYPosition + mt_HalfOfArrowHeight; // Plus half of the tap note so that it will be overlapping
					float bodyBottomY = note.m_fStopYPosition + mt_HalfOfArrowHeight; // Make space for bottom cap
					
					// Determine the track X position now
					float holdX = 0.0f;
					
					if( i == kAvailableTrack_Left )
						holdX = mt_ArrowLeftX;
					if( i == kAvailableTrack_Down )
						holdX = mt_ArrowDownX;
					if( i == kAvailableTrack_Up )
						holdX = mt_ArrowUpX;
					if( i == kAvailableTrack_Right )
						holdX = mt_ArrowRightX;
					
					// Calculate the height of the hold's body
					float totalBodyHeight = bodyTopY - bodyBottomY;
					float offset = bodyBottomY;
					
					// Draw every piece separately
					do{
						float sizeOfPiece = totalBodyHeight > mt_HoldBodyPieceHeight ? mt_HoldBodyPieceHeight : totalBodyHeight;
						
						// Don't draw if we are out of screen
						if(offset+sizeOfPiece > 0.0f) {					
							if(note.m_bIsHolding) {
								[t_HoldNoteActive drawBodyPieceWithSize:sizeOfPiece atPoint:CGPointMake(holdX, offset)];
							} else {
								[t_HoldNoteInactive drawBodyPieceWithSize:sizeOfPiece atPoint:CGPointMake(holdX, offset)];
							}
						}
						
						totalBodyHeight -= mt_HoldBodyPieceHeight;
						offset += mt_HoldBodyPieceHeight;
					} while(totalBodyHeight > 0.0f);					
					
					// determine the position of the cap and draw it if needed
					if(bodyBottomY > 0.0f) {
						// Ok. must draw the cap
						glEnable(GL_BLEND);

						if(note.m_bIsHolding) {
							[t_HoldBottomCapActive drawInRect:CGRectMake(holdX, bodyBottomY-(mt_HoldCapHeight-1), mt_HoldCapWidth, mt_HoldCapHeight)];
						} else {
							[t_HoldBottomCapInactive drawInRect:CGRectMake(holdX, bodyBottomY-(mt_HoldCapHeight-1), mt_HoldCapWidth, mt_HoldCapWidth)];
						}
						
						glDisable(GL_BLEND);
					}
				}
				
				if( i == kAvailableTrack_Left ) {
					CGRect arrowRect = CGRectMake(mt_ArrowLeftX, note.m_fStartYPosition, mt_ArrowWidth, mt_ArrowHeight);
					if(note.m_nType == kNoteType_HoldHead) {
						if(note.m_bIsHolding) {
							[t_TapNote drawHoldTapNoteHolding:note.m_nBeatType direction:kNoteDirection_Left inRect:arrowRect];
						} else { 
							[t_TapNote drawHoldTapNoteReleased:note.m_nBeatType direction:kNoteDirection_Left inRect:arrowRect];	
						}
					} else {
						[t_TapNote drawTapNote:note.m_nBeatType direction:kNoteDirection_Left inRect:arrowRect];
					}
				}
				else if( i == kAvailableTrack_Down ) {
					CGRect arrowRect = CGRectMake(mt_ArrowDownX, note.m_fStartYPosition, mt_ArrowWidth, mt_ArrowHeight);
					if(note.m_nType == kNoteType_HoldHead) {
						if(note.m_bIsHolding) {
							[t_TapNote drawHoldTapNoteHolding:note.m_nBeatType direction:kNoteDirection_Down inRect:arrowRect];
						} else { // if(note.isHoldLost == YES) {
							[t_TapNote drawHoldTapNoteReleased:note.m_nBeatType direction:kNoteDirection_Down inRect:arrowRect];	
						}
					} else {
						[t_TapNote drawTapNote:note.m_nBeatType direction:kNoteDirection_Down inRect:arrowRect];
					}
				}
				else if( i == kAvailableTrack_Up ) {
					CGRect arrowRect = CGRectMake(mt_ArrowUpX, note.m_fStartYPosition, mt_ArrowWidth, mt_ArrowHeight);
					if(note.m_nType == kNoteType_HoldHead) {
						if(note.m_bIsHolding) {
							[t_TapNote drawHoldTapNoteHolding:note.m_nBeatType direction:kNoteDirection_Up inRect:arrowRect];
						} else { // if(note.isHoldLost == YES) {
							[t_TapNote drawHoldTapNoteReleased:note.m_nBeatType direction:kNoteDirection_Up inRect:arrowRect];	
						}
					} else {
						[t_TapNote drawTapNote:note.m_nBeatType direction:kNoteDirection_Up inRect:arrowRect];
					}
				}
				else if( i == kAvailableTrack_Right ) {
					CGRect arrowRect = CGRectMake(mt_ArrowRightX, note.m_fStartYPosition, mt_ArrowWidth, mt_ArrowHeight);
					if(note.m_nType == kNoteType_HoldHead) {
						if(note.m_bIsHolding) {
							[t_TapNote drawHoldTapNoteHolding:note.m_nBeatType direction:kNoteDirection_Right inRect:arrowRect];
						} else { // if(note.isHoldLost == YES) {
							[t_TapNote drawHoldTapNoteReleased:note.m_nBeatType direction:kNoteDirection_Right inRect:arrowRect];	
						}
					} else {						
						[t_TapNote drawTapNote:note.m_nBeatType direction:kNoteDirection_Right inRect:arrowRect];
					}
				}
			}
		}

		// Draw the lifebar above all notes
		[m_pLifeBar render:fDelta];

		// Draw the judgement
		[t_Judgement render:fDelta];
		[t_HoldJudgement render:fDelta];
	}
	
}
@end
