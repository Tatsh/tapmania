//
//  SongPlayRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "SongPlayRenderer.h"
#import "TexturesHolder.h"
#import "TapManiaAppDelegate.h"
#import "SoundEngine.h"
#import "SoundEffectsHolder.h"
#import "TimingUtil.h"
#import "SongsDirectoryCache.h"
#import "DWIParser.h"

#import "SongResultsRenderer.h"

#import "TMSong.h"
#import "TMTrack.h"
#import "TMSongOptions.h"
#import "TMChangeSegment.h"

#import <syslog.h>
#import <math.h>

#define kArrowsBaseX				23
#define kArrowsBaseY				380	// This is the place where the arrows will match with the base
#define kArrowsBaseWidth			274 // 6px spacing between arrows
#define kArrowsBaseHeight			64

#define kLifeBarY					kArrowsBaseY+kArrowsBaseHeight+4

#define kArrowLeftX					23
#define kArrowDownX					93
#define kArrowUpX					163
#define kArrowRightX				233	

#define kHoldBodyPieceHeight		128.0f

@implementation SongPlayRenderer

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	// Init the receptor row
	receptorRow = [[ReceptorRow alloc] initOnPosition:CGPointMake(kArrowsBaseX, kArrowsBaseY)];

	// Init the lifebar
	lifeBar = [[LifeBar alloc] initWithRect:CGRectMake(0.0f, kLifeBarY, 320.0f, 32.0f)];

	playingGame = NO;
	
	return self;
}


- (void) dealloc {
	// Unload bg music track
	SoundEngine_UnloadBackgroundMusicTrack();
	
	[lifeBar release];
	[receptorRow release];
		
	[super dealloc];
}

- (void) playSong:(TMSong*) lSong withOptions:(TMSongOptions*) options {
	TapNote* tapNote = (TapNote*)[[TexturesHolder sharedInstance] getTexture:kTexture_TapNote];	
	
	song = [lSong retain];
	steps = [song getStepsForDifficulty:options.difficulty];

	speedModValue = [TMSongOptions speedModToValue:options.speedMod];
	
	int i;
	
	// Drop track positions to first elements
	for(i=0; i<kNumOfAvailableTracks; i++) {
		trackPos[i] = 0;
	}
	
	SoundEngine_LoadBackgroundMusicTrack([song.musicFilePath UTF8String], NO, YES);
	
	// Calculate starting offset for music playback
	double now = [TimingUtil getCurrentTime];
	double timeOfFirstBeat = [TimingUtil getElapsedTimeFromBeat:[TMNote noteRowToBeat:[steps getFirstNoteRow]] inSong:song];
	double timeOfLastBeat = [TimingUtil getElapsedTimeFromBeat:[TMNote noteRowToBeat:[steps getLastNoteRow]] inSong:song];
	
	if(timeOfFirstBeat <= kMinTimeTillStart){
		playBackStartTime = now + kMinTimeTillStart;
		musicPlaybackStarted = NO;
	} else {	
		playBackStartTime = now;
		musicPlaybackStarted = YES;
		SoundEngine_StartBackgroundMusic();
	}

	playBackScheduledEndTime = playBackStartTime + timeOfLastBeat + kTimeTillMusicStop;
	
	[tapNote startAnimation];
	
	// Enable joypad
	joyPad = [[TapMania sharedInstance] enableJoyPad];

	playingGame = YES;	
}

// Updates one frame of the gameplay
- (void)update:(NSNumber*)fDelta {	
	if(!playingGame) return;
		
	TapNote* tapNote = (TapNote*)[[TexturesHolder sharedInstance] getTexture:kTexture_TapNote];
	Judgement* judgement = (Judgement*)[[TexturesHolder sharedInstance] getTexture:kTexture_Judgement];	
	
	// Calculate current elapsed time
	double currentTime = [TimingUtil getCurrentTime];
	double elapsedTime = currentTime - playBackStartTime;
	
	// Start music with delay if required
	if(!musicPlaybackStarted) {
		if(playBackStartTime <= currentTime){
			musicPlaybackStarted = YES;
			SoundEngine_StartBackgroundMusic();
		}
	} else if(currentTime >= playBackScheduledEndTime) {
		// Should stop music and stop gameplay now
		// TODO: some fadeout would be better
		SoundEngine_StopBackgroundMusic(NO);
		
		// Stop animating the arrows
		[tapNote stopAnimation];
	
		// Disable the joypad
		[[TapMania sharedInstance] disableJoyPad];
	
		// request transition
		SongResultsRenderer *srScreen = [[SongResultsRenderer alloc] initWithSong:song withSteps:steps];
		
		[[TapMania sharedInstance] switchToScreen:srScreen];
		playingGame = NO;
	}	
	
	float currentBeat, currentBps;
	BOOL hasFreeze;
	
	[TimingUtil getBeatAndBPSFromElapsedTime:elapsedTime beatOut:&currentBeat bpsOut:&currentBps freezeOut:&hasFreeze inSong:song]; 
	
	// Calculate animation of the tap notes. The speed of the animation is actually one frame per beat
	[tapNote setFrameTime:[TimingUtil getTimeInBeatForBPS:currentBps]];
	[tapNote update:fDelta];

	// Update receptor row animations
	[receptorRow update:fDelta];
	
	// Update judgement state
	[judgement update:fDelta];
	
	// If freeze - leave for now
	if(hasFreeze) {
		[tapNote pauseAnimation];
		return;
	} 
	
	[tapNote continueAnimation];
	
	double searchHitFromTime = elapsedTime - 0.1f;
	double searchHitTillTime = elapsedTime + 0.1f;
	int i;
	
	// For every track
	for(i=0; i<kNumOfAvailableTracks; i++) {
		// Search in this track for items starting at index:
		int startIndex = trackPos[i];
		int j;
		
		// This will hold the Y coordinate of the previous note in this track
		float lastNoteYPosition = kArrowsBaseY;
		
		TMNote* prevNote = nil;
		
		double lastHitTime = [joyPad getTouchTimeForButton:i] - playBackStartTime;
		BOOL testHit = NO;

		// Check for hit?
		if(lastHitTime >= searchHitFromTime && lastHitTime <= searchHitTillTime) {
			testHit = YES;
		}
		 
		// For all interesting notes in the track
		for(j=startIndex; j<[steps getNotesCountForTrack:i] ; j++) {
			TMNote* note = [steps getNote:j fromTrack:i];
			
			// We are not handling empty notes though
			if(note.type == kNoteType_Empty)
				continue;
			
			// Get beats out of noteRows
			float beat = [TMNote noteRowToBeat: note.startNoteRow];
			float tillBeat = note.stopNoteRow == -1 ? -1.0f : [TMNote noteRowToBeat: note.stopNoteRow];
			
			float noteBps = [TimingUtil getBpsAtBeat:beat inSong:song];
			
			float noteYPosition = lastNoteYPosition;
			float holdBottomCapYPosition = 0.0f;
			
			int lastNoteRow = prevNote ? prevNote.startNoteRow : [TMNote beatToNoteRow:currentBeat];
			int nextBpmChangeNoteRow = [TimingUtil getNextBpmChangeFromBeat:[TMNote noteRowToBeat:lastNoteRow] inSong:song];
			
			double noteTime = [TimingUtil getElapsedTimeFromBeat:beat inSong:song];
			
			// Now for every bpmchange we must apply all bpmchange related offsets
			while (nextBpmChangeNoteRow != -1 && nextBpmChangeNoteRow < note.startNoteRow) {
				float tBps = [TimingUtil getBpsAtBeat:[TMNote noteRowToBeat:nextBpmChangeNoteRow-1] inSong:song];
				
				noteYPosition -= (nextBpmChangeNoteRow-lastNoteRow)*[TimingUtil getPixelsPerNoteRowForBPS:tBps andSpeedMod:speedModValue];
				lastNoteRow = nextBpmChangeNoteRow;
				nextBpmChangeNoteRow = [TimingUtil getNextBpmChangeFromBeat:[TMNote noteRowToBeat:nextBpmChangeNoteRow] inSong:song];
			}
			
			// Calculate for last segment
			noteYPosition -= (note.startNoteRow-lastNoteRow)*[TimingUtil getPixelsPerNoteRowForBPS:noteBps andSpeedMod:speedModValue];
			note.startYPosition = noteYPosition;
			
			/* We must also calculate the Y position of the bottom cap of the hold if we handle a hold note */
			if(note.type == kNoteType_HoldHead) {
				// If we hold the note now we must fix it on the receptor base
				if(note.isHolding) {
					note.startYPosition = kArrowsBaseY;
				}
				
				// Start from the calculated note head position
				holdBottomCapYPosition = noteYPosition;
				lastNoteRow = note.startNoteRow;
				
				nextBpmChangeNoteRow = [TimingUtil getNextBpmChangeFromBeat:[TMNote noteRowToBeat:lastNoteRow] inSong:song];
				
				// Now for every bpmchange we must apply all bpmchange related offsets
				while (nextBpmChangeNoteRow != -1 && nextBpmChangeNoteRow < note.stopNoteRow) {
					float tBps = [TimingUtil getBpsAtBeat:[TMNote noteRowToBeat:nextBpmChangeNoteRow-1] inSong:song];
					
					holdBottomCapYPosition -= (nextBpmChangeNoteRow-lastNoteRow)*[TimingUtil getPixelsPerNoteRowForBPS:tBps andSpeedMod:speedModValue];
					lastNoteRow = nextBpmChangeNoteRow;
					nextBpmChangeNoteRow = [TimingUtil getNextBpmChangeFromBeat:[TMNote noteRowToBeat:nextBpmChangeNoteRow] inSong:song];
				}
				
				// Calculate for last segment of the hold body
				float capBps = [TimingUtil getBpsAtBeat:tillBeat inSong:song];
				holdBottomCapYPosition -= (note.stopNoteRow-lastNoteRow)*[TimingUtil getPixelsPerNoteRowForBPS:capBps andSpeedMod:speedModValue];			
				
				note.stopYPosition = holdBottomCapYPosition;
			}
			
			// Check whether we already missed a note (hold head too)
			if(!note.isLost && !note.isHit && (elapsedTime-noteTime)>=0.1f) {
				[steps markAllNotesLostFromRow:note.startNoteRow];		
				[note score:kNoteScore_Miss];	// Only one of the notes get the scoring set

				[judgement setCurrentJudgement:kJudgementMiss];
				[lifeBar updateBy:[TimingUtil getLifebarChangeByNoteScore:kNoteScore_Miss]];
			}
			
			// Check whether this note is already out of scope
			if(note.type != kNoteType_HoldHead && noteYPosition >= 480.0f) {
				++trackPos[i];				
				continue; // Skip this note
			}

			// Now the same for hold notes
			if(note.type == kNoteType_HoldHead) {
				if(note.isHeld && holdBottomCapYPosition >= kArrowsBaseY) {
					// We could loose the hold till here so we didn't do any life bar actions neither did we show OK yet.
					[lifeBar updateBy:0.05];
					++trackPos[i];
				} else if (note.isHoldLost && holdBottomCapYPosition >= 480.0f) {
					// Let the hold go till the end of the screen. The lifebar and the NG graphic is done already when the hold was lost
					++trackPos[i];
				}				
			}
			
			// If the Y position is at the floor - jump to next track
			if(note.startYPosition <= -64.0f){
				break; // Start another track coz this note is out of screen
			}				
			
			// Check old hit first
			if(testHit && note.isHit){
				// This note was hit already (maybe using the same tap as we still hold)
				if(note.hitTime == lastHitTime) {
					// Bingo! prevent further notes in this track from being hit
					testHit = NO;
				} 
			}
			 
			// If we are at a hold arrow we must check it anyway
			if(note.type == kNoteType_HoldHead) {
				double lastReleaseTime = [joyPad getReleaseTimeForButton:i] - playBackStartTime;
				
				if(note.isHit && !note.isHoldLost && !note.isHolding) {
					// This means we released the hold but we still can catch it again
					if(fabsf(elapsedTime - note.lastHoldReleaseTime) >= 0.8f) {
						[note markHoldLost];
						[lifeBar updateBy:-0.05];	// NG judgement
					}
					
					// But maybe we have touched it again before it was marked as lost totally?
					if(!note.isHoldLost && note.lastHoldReleaseTime < lastHitTime) {
						[note startHolding:lastHitTime];
					}
				} else if(note.isHit && !note.isHoldLost && note.isHolding) {				
					if(lastReleaseTime > lastHitTime) {						
						[note stopHolding:lastReleaseTime];
					}
				} 
			}
			
			// Check hit
			if(testHit && !note.isLost && !note.isHit){
				if(noteTime >= searchHitFromTime && noteTime <= searchHitTillTime) {
				
					// Mark note as hit
					[note hit:lastHitTime];
					testHit = NO; // Don't want to test hit on other notes on the track in this run
					
					if(note.type == kNoteType_HoldHead) {
						[note startHolding:lastHitTime];
					}
					
					// Check whether other tracks has any notes which are not hit yet and are on the same noterow
					double timesOfHit[kNumOfAvailableTracks];
					BOOL allNotesHit = [steps checkAllNotesHitFromRow:note.startNoteRow time1Out:&timesOfHit[0] time2Out:&timesOfHit[1] time3Out:&timesOfHit[2] time4Out:&timesOfHit[3]];
					
					// After the previous check we should know whether all the notes on the noterow are already hit
					if(allNotesHit == YES) {					
					
						// Get the worse scoring of all hit notes
						double worseDelta = 0.0f;
						
						int tr = 0;
						for(; tr<kNumOfAvailableTracks; ++tr){
							if(timesOfHit[tr] != 0.0f) {
								double thisDelta = fabs(noteTime-timesOfHit[tr]);

								if(thisDelta > worseDelta) 
									worseDelta = thisDelta;
							}
						}
						
						TMNoteScore noteScore = [TimingUtil getNoteScoreByDelta:worseDelta];
						TMJudgement noteJudgement = [TimingUtil getJudgementByScore:noteScore];
						
						// Set the score to the note (group of notes. only one will count anyway)
						[note score:noteScore];
						
						[judgement setCurrentJudgement:noteJudgement];
						[lifeBar updateBy:[TimingUtil getLifebarChangeByNoteScore:noteScore]];
						
						// Explode all hit tracks
						for(tr=0; tr<kNumOfAvailableTracks; ++tr){
							if(timesOfHit[tr] != 0.0f) {								
								[receptorRow explodeBright:tr];
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
- (void)render:(NSNumber*)fDelta {
	CGRect bounds = [TapMania sharedInstance].glView.bounds;
	TapNote* tapNote = (TapNote*)[[TexturesHolder sharedInstance] getTexture:kTexture_TapNote];
	
	HoldNote* holdNoteInactive = (HoldNote*)[[TexturesHolder sharedInstance] getTexture:kTexture_HoldBodyInactive];
	HoldNote* holdNoteActive = (HoldNote*)[[TexturesHolder sharedInstance] getTexture:kTexture_HoldBodyActive];
	
	Judgement* judgement = (Judgement*)[[TexturesHolder sharedInstance] getTexture:kTexture_Judgement];	
	
	//Draw background TODO: spread/index
	glDisable(GL_BLEND);
	[[[TexturesHolder sharedInstance] getTexture:kTexture_SongPlayBackgroundSpread] drawInRect:bounds];
	glEnable(GL_BLEND);
		
	if(!playingGame) return;

	// Draw the receptor row
	[receptorRow render:fDelta];
		
	int i;
	
	// For every track
	for(i=0; i<kNumOfAvailableTracks; i++) {
		
		// Search in this track for items starting at index:
		int startIndex = trackPos[i];
		int j;
	
		// For all interesting notes in the track
		for(j=startIndex; j<[steps getNotesCountForTrack:i] ; j++) {
			TMNote* note = [steps getNote:j fromTrack:i];
			
			// We are not handling empty notes though
			if(note.type == kNoteType_Empty)
				continue;
			
			// We will draw the note only if it wasn't hit yet
			if(note.type == kNoteType_HoldHead || !note.isHit) {
				if(note.startYPosition <= -64.0f) {
					break; // Start another track coz this note is out of screen
				}
				
				// If note is a holdnote
				if(note.type == kNoteType_HoldHead) {			
					// Calculate body length
					float bodyTopY = note.startYPosition + 32.0f; // Plus half of the tap note so that it will be overlapping
					float bodyBottomY = note.stopYPosition + 32.0f; // Make space for bottom cap
					
					// Determine the track X position now
					float holdX = 0.0f;
					
					if( i == kAvailableTrack_Left )
						holdX = kArrowLeftX;
					if( i == kAvailableTrack_Down )
						holdX = kArrowDownX;
					if( i == kAvailableTrack_Up )
						holdX = kArrowUpX;
					if( i == kAvailableTrack_Right )
						holdX = kArrowRightX;
					
					// Calculate the height of the hold's body
					float totalBodyHeight = bodyTopY - bodyBottomY;
					float offset = bodyBottomY;
					
					// Draw every piece separately
					do{
						float sizeOfPiece = totalBodyHeight > kHoldBodyPieceHeight ? kHoldBodyPieceHeight : totalBodyHeight;
						
						// Don't draw if we are out of screen
						if(offset+sizeOfPiece > 0.0f) {					
							if(note.isHolding) {
								[holdNoteActive drawBodyPieceWithSize:sizeOfPiece atPoint:CGPointMake(holdX, offset)];
							} else {
								[holdNoteInactive drawBodyPieceWithSize:sizeOfPiece atPoint:CGPointMake(holdX, offset)];
							}
						}
						
						totalBodyHeight -= kHoldBodyPieceHeight;
						offset += kHoldBodyPieceHeight;
					} while(totalBodyHeight > 0.0f);					
					
					// determine the position of the cap and draw it if needed
					if(bodyBottomY > 0.0f) {
						// Ok. must draw the cap
						if(note.isHolding) {
							[[[TexturesHolder sharedInstance] getTexture:kTexture_HoldBottomCapActive] drawInRect:CGRectMake(holdX, bodyBottomY-63.0f, 64.0f, 64.0f)];
						} else {
							[[[TexturesHolder sharedInstance] getTexture:kTexture_HoldBottomCapInactive] drawInRect:CGRectMake(holdX, bodyBottomY-63.0f, 64.0f, 64.0f)];
						}
					}
				}
				
				if( i == kAvailableTrack_Left ) {
					CGRect arrowRect = CGRectMake(kArrowLeftX, note.startYPosition , 64, 64);
					if(note.isHolding) {
						[tapNote drawHoldTapNote:note.beatType direction:kNoteDirection_Left inRect:arrowRect];
					} else {
						[tapNote drawTapNote:note.beatType direction:kNoteDirection_Left inRect:arrowRect];
					}
				}
				else if( i == kAvailableTrack_Down ) {
					CGRect arrowRect = CGRectMake(kArrowDownX, note.startYPosition, 64, 64);
					if(note.isHolding) {
						[tapNote drawHoldTapNote:note.beatType direction:kNoteDirection_Down inRect:arrowRect];
					} else {
						[tapNote drawTapNote:note.beatType direction:kNoteDirection_Down inRect:arrowRect];
					}
				}
				else if( i == kAvailableTrack_Up ) {
					CGRect arrowRect = CGRectMake(kArrowUpX, note.startYPosition, 64, 64);
					if(note.isHolding) {
						[tapNote drawHoldTapNote:note.beatType direction:kNoteDirection_Up inRect:arrowRect];
					} else {
						[tapNote drawTapNote:note.beatType direction:kNoteDirection_Up inRect:arrowRect];
					}
				}
				else if( i == kAvailableTrack_Right ) {
					CGRect arrowRect = CGRectMake(kArrowRightX, note.startYPosition, 64, 64);
					if(note.isHolding) {
						[tapNote drawHoldTapNote:note.beatType direction:kNoteDirection_Right inRect:arrowRect];
					} else {						
						[tapNote drawTapNote:note.beatType direction:kNoteDirection_Right inRect:arrowRect];
					}
				}
			}
		}

		// Draw the lifebar above all notes
		[lifeBar render:fDelta];

		// Draw the judgement
		[judgement render:fDelta];
	}
	
}
@end
