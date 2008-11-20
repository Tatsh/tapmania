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

#import "TMSong.h"
#import "TMTrack.h"
#import "TMSongOptions.h"
#import "TMChangeSegment.h"

#import <syslog.h>
#import <math.h>

#define kArrowsBaseX				25
#define kArrowsBaseY				380	// This is the place where the arrows will match with the base
#define kArrowsBaseWidth			270
#define kArrowsBaseHeight			60

#define kArrowLeftX					25
#define kArrowDownX					96
#define kArrowUpX					165
#define kArrowRightX				235	

@implementation SongPlayRenderer

- (id) initWithView:(EAGLView*)lGlView {
	self = [super initWithView:lGlView];
	if(!self)
		return nil;
	
	// Show joyPad
	[(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] showJoyPad];
	joyPad = [(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] joyPad];
	
	return self;
}

- (void) playSong:(TMSong*) lSong withOptions:(TMSongOptions*) options {
	
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
	
	// Start rendering
	[(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] activateRenderer:self looping:YES];	
}

// Renders one scene of the gameplay
- (void)renderScene {
	CGRect				bounds = [glView bounds];
	
	//Draw background
	glDisable(GL_BLEND);
	[[[TexturesHolder sharedInstance] getTexture:kTexture_Background] drawInRect:bounds];
	glEnable(GL_BLEND);
		
	// Draw the base
	CGRect baseRect = CGRectMake(kArrowsBaseX, kArrowsBaseY, kArrowsBaseWidth, kArrowsBaseHeight);
	[[[TexturesHolder sharedInstance] getTexture:kTexture_BaseDark] drawInRect:baseRect];
		
	// Calculate current elapsed time
	double currentTime = [TimingUtil getCurrentTime];
	double elapsedTime = currentTime - playBackStartTime;
	
	float currentBeat, currentBps;
	BOOL hasFreeze;
	
	[TimingUtil getBeatAndBPSFromElapsedTime:elapsedTime beatOut:&currentBeat bpsOut:&currentBps freezeOut:&hasFreeze inSong:song]; 
	
	// If freeze - leave for now
	if(hasFreeze) return;
	
	/*
	 Now trackPos[i] for every 'i' contains the first element which is still on screen
	 Our goal here is to find all the notes from 'i' to whatever it takes with time less than 
	 currentTime + fullScreenTime.

	 TODO: the time delta to search a hit should be calculated dynamically depending on bpm and speed mod (probably)

	 TODO: only one note in a track should be hit by one single touch.

	 		timeline of one track
	 0	|	|	|	|	|	|	trackend
	 [--------h-N-r-----N----h--N-N-r-----------------------]
	 			 |	|
				 --------
		two notes are in the way while we hold our tap
		h = 2.30	r = 2.90	N1 = 2.4	N2 = 2.6
		
		check every note whether:
		1) it was hit already
		2) the time of the hit is the same as the last tap time
	 */
	double searchHitFromTime = elapsedTime - 0.2f;
	double searchHitTillTime = elapsedTime + 0.2f;
	int i;
	
	// For every track
	for(i=0; i<kNumOfAvailableTracks; i++) {
	
		// Search in this track for items starting at index:
		int startIndex = trackPos[i];
		int j;
		
		double lastHitTime = 0.0f;
		BOOL testHit = NO;
	
		// Check for hit?
		if([joyPad getStateForButton:i]) {
			// Button is currently pressed
			lastHitTime = [joyPad getTouchTimeForButton:i] - playBackStartTime;

			if(lastHitTime >= searchHitFromTime && lastHitTime <= searchHitTillTime) {
				testHit = YES;
			}
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
			
			float noteTime = [TimingUtil getElapsedTimeFromBeat:beat inSong:song];
			float noteTillTime = tillBeat == -1.0f ? -1.0f : [TimingUtil getElapsedTimeFromBeat:tillBeat inSong:song];
	
			// Check whether this note is already out of scope
			if((note.type == kNoteType_HoldHead && noteTillTime < elapsedTime) || (note.type != kNoteType_HoldHead && noteTime < elapsedTime)) {
				++trackPos[i];
				if(!note.isHit) {
					// syslog(LOG_DEBUG, "Miss!");
				}
				
				continue; // Skip this note
			}
			
			currentBps = [TimingUtil getBpmAtBeat:beat inSong:song]/60.0f;
						
			// Get times at that beat
			double fullScreenTime = kArrowsBaseY/currentBps/60.0f;
			double timePerBeat = [TimingUtil getTimeInBeatForBPS:currentBps];	
			
			// Apply speedmod
			if(speedModValue != -1) {
				fullScreenTime /= speedModValue;
			}			
						
			// Check old hit first
			if(testHit && note.isHit){
				// This note was hit already (maybe using the same tap as we still hold)
				if(note.hitTime == lastHitTime) {
					// Bingo! prevent further notes in this track from being hit
					testHit = NO;
				}
			}
			
					
			// Check hit
			if(testHit && !note.isHit){
				
				if(noteTime >= searchHitFromTime && noteTime <= searchHitTillTime) {
					// Ok. we take this input
					double delta = fabs(noteTime - lastHitTime);
					
					if(delta <= 0.05) {
						// syslog(LOG_DEBUG, "Marvelous!");
					} else if(delta <= 0.1) {
						// syslog(LOG_DEBUG, "Perfect!");
					} else if(delta <= 0.15) {
						// syslog(LOG_DEBUG, "Great!");
					} else if(delta <= 0.17) {
						// syslog(LOG_DEBUG, "Almost!");
					} else if(delta <= 0.19) {
						// syslog(LOG_DEBUG, "BOO!");
					} else {
						// syslog(LOG_DEBUG, "Miss!");
					}
			
					// Mark note as hit
					[note hit:lastHitTime];
					testHit = NO; // Don't want to test hit on other notes on the track in this run
				}
			}
			 
			// We will draw the note only if it wasn't hit yet
			if(note.type == kNoteType_HoldHead || !note.isHit) {
				// If the time is inside the search region - calculate the Y position on screen and draw the note
				float noteOffsetY = kArrowsBaseY- ( kArrowsBaseY/fullScreenTime * (noteTime-elapsedTime) );
			
				if(noteOffsetY <= 0 && note.type != kNoteType_HoldHead){
					break; // Start another track coz this note is out of screen
				}
				
				// If note is a holdnote
				if(note.type == kNoteType_HoldHead) {
					// Calculate body length
					float bodyTopY = noteOffsetY + 30; // Plus half of the tap note so that it will be overlapping
					float bodyBottomY = kArrowsBaseY- ( kArrowsBaseY/fullScreenTime * (noteTillTime-elapsedTime) ) + 25;
					
					// Bottom Y can be out of the screen bounds and if so must be set to 0 - bottom of screen
					if(bodyBottomY < 0.0f) 
						bodyBottomY = 0.0f;
					
					// Top Y can be out of screen as well
					if(bodyTopY > glView.bounds.size.height){
						bodyTopY = glView.bounds.size.height;
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
					float sizeOfHold = bodyTopY - bodyBottomY;
					
					CGRect bodyRect = CGRectMake(holdX, bodyBottomY, 60, sizeOfHold);
					[[[TexturesHolder sharedInstance] getTexture:kTexture_HoldBody] drawInRect:bodyRect];
					
					// Now if bottom of the hold is visible on the screen - draw the cap
					if(bodyBottomY > 0.0f) {
						CGRect bodyCapRect = CGRectMake(holdX, bodyBottomY-20, 60, 20);
						[[[TexturesHolder sharedInstance] getTexture:kTexture_HoldBottom] drawInRect:bodyCapRect];					
					}
				}
				
				
				if( i == kAvailableTrack_Left ) {
					CGRect arrowRect = CGRectMake(kArrowLeftX, noteOffsetY, 60, 60);
					[[[TexturesHolder sharedInstance] getArrowTextureForType:note.beatType andDir:kNoteDirection_Left] drawInRect:arrowRect];
				}
				else if( i == kAvailableTrack_Down ) {
					CGRect arrowRect = CGRectMake(kArrowDownX, noteOffsetY, 60, 60);
					[[[TexturesHolder sharedInstance] getArrowTextureForType:note.beatType andDir:kNoteDirection_Down] drawInRect:arrowRect];
				}
				else if( i == kAvailableTrack_Up ) {
					CGRect arrowRect = CGRectMake(kArrowUpX, noteOffsetY, 60, 60);
					[[[TexturesHolder sharedInstance] getArrowTextureForType:note.beatType andDir:kNoteDirection_Up] drawInRect:arrowRect];
				}
				else if( i == kAvailableTrack_Right ) { 
					CGRect arrowRect = CGRectMake(kArrowRightX, noteOffsetY, 60, 60);
					[[[TexturesHolder sharedInstance] getArrowTextureForType:note.beatType andDir:kNoteDirection_Right] drawInRect:arrowRect];					
				}
			}
		}
	}
		
	//Swap the framebuffer
	[glView swapBuffers];
}

@end
