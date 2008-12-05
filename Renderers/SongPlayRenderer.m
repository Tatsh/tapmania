//
//  SongPlayRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "SongPlayRenderer.h"
#import "RenderEngine.h"
#import "TexturesHolder.h"
#import "TapManiaAppDelegate.h"
#import "SoundEngine.h"
#import "SoundEffectsHolder.h"
#import "TimingUtil.h"
#import "SongsDirectoryCache.h"
#import "DWIParser.h"

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

#define kArrowLeftX					23
#define kArrowDownX					93
#define kArrowUpX					163
#define kArrowRightX				233	

@implementation SongPlayRenderer

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	// Show joyPad
//	[(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] showJoyPad];
//	joyPad = [(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] joyPad];

	playing = NO;
	
	return self;
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
	
	SoundEngine_LoadBackgroundMusicTrack([song.musicFilePath UTF8String], NO, NO);
	
	// Save start time of song playback and start the playback
	playBackStartTime = [TimingUtil getCurrentTime];
	SoundEngine_StartBackgroundMusic();

	[tapNote startAnimation];
	playing = YES;	
}

// Updates one frame of the gameplay
- (void)update:(NSNumber*)fDelta {
	if(!playing) return;
	
	TapNote* tapNote = (TapNote*)[[TexturesHolder sharedInstance] getTexture:kTexture_TapNote];
	
	// Calculate current elapsed time
	double currentTime = [TimingUtil getCurrentTime];
	double elapsedTime = currentTime - playBackStartTime;
	
	float currentBeat, currentBps;
	BOOL hasFreeze;
	
	[TimingUtil getBeatAndBPSFromElapsedTime:elapsedTime beatOut:&currentBeat bpsOut:&currentBps freezeOut:&hasFreeze inSong:song]; 
	
	// Calculate animation of the tap notes
	[tapNote setFrameTime:[TimingUtil getTimeInBeatForBPS:currentBps]/8];
	[tapNote update:fDelta];
	
	// If freeze - leave for now
	if(hasFreeze) {
		[tapNote pauseAnimation];
		return;
	} 
	
	[tapNote continueAnimation];
	
	// double searchHitFromTime = elapsedTime - 0.1f;
	// double searchHitTillTime = elapsedTime + 0.1f;
	int i;
	
	// For every track
	for(i=0; i<kNumOfAvailableTracks; i++) {
		
		// Search in this track for items starting at index:
		int startIndex = trackPos[i];
		int j;
		
		// This will hold the Y coordinate of the previous note in this track
		float lastNoteYPosition = kArrowsBaseY;
		
		TMNote* prevNote = nil;
		
		// double lastHitTime = 0.0f;
		// BOOL testHit = NO;
		
		// Check for hit?
		/*
		if([joyPad getStateForButton:i]) {
			// Button is currently pressed
			lastHitTime = [joyPad getTouchTimeForButton:i] - playBackStartTime;
			
			if(lastHitTime >= searchHitFromTime && lastHitTime <= searchHitTillTime) {
				testHit = YES;
			}
		}
		*/
		 
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
			
			// Check whether this note is already out of scope
			if((note.type == kNoteType_HoldHead && holdBottomCapYPosition >= 480.0f) || (note.type != kNoteType_HoldHead && noteYPosition >= 480.0f)) {
				++trackPos[i];
				/*
				if(!note.isHit) {
					// syslog(LOG_DEBUG, "Miss!");
				}
				*/
				continue; // Skip this note
			}
			
			// If the Y position is at the floor - jump to next track
			if(note.startYPosition <= 0){
				break; // Start another track coz this note is out of screen
			}				
			
			// Check old hit first
			/*
			if(testHit && note.isHit){
				// This note was hit already (maybe using the same tap as we still hold)
				if(note.hitTime == lastHitTime) {
					// Bingo! prevent further notes in this track from being hit
					testHit = NO;
				} 
			}
			*/
			 
			// Check hit
			/*
			if(testHit && !note.isHit){
				
				if(noteTime >= searchHitFromTime && noteTime <= searchHitTillTime) {
					// Ok. we take this input
					double delta = fabs(noteTime - lastHitTime);
					
					if(delta <= 0.01) {
						// syslog(LOG_DEBUG, "Marvelous!");
					} else if(delta <= 0.05) {
						// syslog(LOG_DEBUG, "Perfect!");
					} else if(delta <= 0.1) {
						// syslog(LOG_DEBUG, "Great!");
					} else if(delta <= 0.13) {
						// syslog(LOG_DEBUG, "Almost!");
					} else if(delta <= 0.18) {
						// syslog(LOG_DEBUG, "BOO!");
					} else {
						// syslog(LOG_DEBUG, "Miss!");
					}
					
					// Mark note as hit
					[note hit:lastHitTime];
					testHit = NO; // Don't want to test hit on other notes on the track in this run
				}
			}
			*/
				
			prevNote = note;
			lastNoteYPosition = noteYPosition;
		}
	}
}

// Renders one scene of the gameplay
- (void)render:(NSNumber*)fDelta {
	CGRect bounds = [RenderEngine sharedInstance].glView.bounds;
	TapNote* tapNote = (TapNote*)[[TexturesHolder sharedInstance] getTexture:kTexture_TapNote];
	
	//Draw background
	glDisable(GL_BLEND);
	[[[TexturesHolder sharedInstance] getTexture:kTexture_Background] drawInRect:bounds];
	glEnable(GL_BLEND);
		
	if(!playing) return;
	
	// Draw the base
	// CGRect baseRect = CGRectMake(kArrowsBaseX, kArrowsBaseY, kArrowsBaseWidth, kArrowsBaseHeight);
	// [[[TexturesHolder sharedInstance] getTexture:kTexture_BaseDark] drawInRect:baseRect];
		
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
				if(note.startYPosition <= 0 && note.type != kNoteType_HoldHead){
					break; // Start another track coz this note is out of screen
				}
				
				// If note is a holdnote
				if(note.type == kNoteType_HoldHead) {
					// Calculate body length
					float bodyTopY = note.startYPosition + 32; // Plus half of the tap note so that it will be overlapping
					float bodyBottomY = note.stopYPosition;
					
					// Bottom Y can be out of the screen bounds and if so must be set to 0 - bottom of screen
					if(bodyBottomY < 0.0f) 
						bodyBottomY = 0.0f;
					
					// Top Y can be out of screen as well
					if(bodyTopY > bounds.size.height){
						bodyTopY = bounds.size.height;
					}
					
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
					float sizeOfHold = bodyTopY-bodyBottomY-30;
					
					CGRect bodyRect = CGRectMake(holdX, bodyBottomY+30, 64, sizeOfHold);
					// [[[TexturesHolder sharedInstance] getTexture:kTexture_HoldBody] drawInRect:bodyRect];
					
					// Now if bottom of the hold is visible on the screen - draw the cap
					if(bodyBottomY > 0.0f) {
						CGRect bodyCapRect = CGRectMake(holdX, bodyBottomY, 64, 30);
						// [[[TexturesHolder sharedInstance] getTexture:kTexture_HoldBottom] drawInRect:bodyCapRect];					
					}
				}
				
				if( i == kAvailableTrack_Left ) {
					CGRect arrowRect = CGRectMake(kArrowLeftX, note.startYPosition , 64, 64);
					[tapNote drawTapNote:note.beatType direction:kNoteDirection_Left inRect:arrowRect];
				}
				else if( i == kAvailableTrack_Down ) {
					CGRect arrowRect = CGRectMake(kArrowDownX, note.startYPosition, 64, 64);
					[tapNote drawTapNote:note.beatType direction:kNoteDirection_Down inRect:arrowRect];
				}
				else if( i == kAvailableTrack_Up ) {
					CGRect arrowRect = CGRectMake(kArrowUpX, note.startYPosition, 64, 64);
					[tapNote drawTapNote:note.beatType direction:kNoteDirection_Up inRect:arrowRect];
				}
				else if( i == kAvailableTrack_Right ) {
					CGRect arrowRect = CGRectMake(kArrowRightX, note.startYPosition, 64, 64);
					[tapNote drawTapNote:note.beatType direction:kNoteDirection_Right inRect:arrowRect];
				}
			}
		}
	}
	
}
@end
