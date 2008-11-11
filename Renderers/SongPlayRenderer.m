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
#import "TimingUtil.h"
#import "SongsDirectoryCache.h"
#import "DWIParser.h"

#import "TMSong.h"
#import "TMTrack.h"
#import "TMSongOptions.h"

#import <syslog.h>

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

- (void) playSong:(TMSong*) lSong onDifficulty:(TMSongDifficulty)difficulty withOptions:(TMSongOptions*) options {
	NSLog(@"Start the song...");
	
	song = lSong;
	steps = [song getStepsForDifficulty:difficulty];
	
	double speedModValue = [TMSongOptions speedModToValue:options.speedMod];
	
	bpmSpeed = song.bpm/kRenderingFPS;
	fullScreenTime = kArrowsBaseY/bpmSpeed/60.0f;	// Full screen is 380px coz we are going till the arrows base with rate of 60 frames per second
		
	// Apply speedmod
	if(speedModValue != -1) {
		fullScreenTime /= speedModValue;
	}
	
	int i;
	
	// Drop track positions to first elements
	for(i=0; i<kNumOfAvailableTracks; i++) {
		trackPos[i] = 0;
	}
	
	NSLog(@"play %@", song.musicFilePath);
	SoundEngine_LoadBackgroundMusicTrack([song.musicFilePath UTF8String], YES, NO);
	
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
	[[[TexturesHolder sharedInstance] getTexture:kTexture_Base] drawInRect:baseRect];
		
	// Calculate current elapsed time
	double currentTime = [TimingUtil getCurrentTime];
	double elapsedTime = currentTime - playBackStartTime;
	
	/*
	 Now trackPos[i] for every 'i' contains the first element which is still on screen
	 Our goal here is to find all the notes from 'i' to whatever it takes with time less than 
	 currentTime + fullScreenTime.
	 */
	double searchTillTime = elapsedTime + fullScreenTime;
	double searchHitFromTime = elapsedTime - 0.2f;
	double searchHitTillTime = elapsedTime + 0.2f;
	
	int i;
	
	for(i=0; i<kNumOfAvailableTracks; i++) {
		
		// Search in this track for items starting at index:
		int startIndex = trackPos[i];
		int j;
		
		double lastHitTime = 0.0f;
		BOOL testHit = NO;
		
		// Check for hit
		if([joyPad getStateForButton:i]) {
			// Button is currently pressed
			lastHitTime = [joyPad getTouchTimeForButton:i] - playBackStartTime;
			testHit = YES;
		}


		for(j=startIndex; j<[steps getNotesCountForTrack:i] ; j++) {
			TMNote* note = [steps getNote:j fromTrack:i];

			if(note.time <= searchHitFromTime) {
				// Found a note which is out of screen now
				++trackPos[i];
				if(!note.isHit) {
					syslog(LOG_DEBUG, "Miss!");
				}
				
				continue; // Skip this note
			}
			
			// Ok, hit a note which is out of scope
			if(note.time > searchTillTime){			
				break;
			}
			
			// Check hit
			if(testHit && !note.isHit){
				if(note.time >= searchHitFromTime && note.time <= searchHitTillTime) {
					// Ok. we take this input
					double delta = fabs(note.time - elapsedTime);
					
					if(delta <= 0.05) {
						syslog(LOG_DEBUG, "Marvelous!");
					} else if(delta <= 0.1) {
						syslog(LOG_DEBUG, "Perfect!");
					} else if(delta <= 0.15) {
						syslog(LOG_DEBUG, "Great!");
					} else if(delta <= 0.17) {
						syslog(LOG_DEBUG, "Almost!");
					} else if(delta <= 0.19) {
						syslog(LOG_DEBUG, "BOO!");
					} else {
						syslog(LOG_DEBUG, "Miss!");
					}
			
					// Mark note as hit
					[note hit:elapsedTime];
				}
			}

			// If the time is inside the search region - calculate the Y position on screen and draw the note
			double noteOffsetY = kArrowsBaseY- ( kArrowsBaseY/fullScreenTime * (note.time-elapsedTime) );
			
			if( i == kAvailableTrack_Left ) {
					CGRect arrowRect = CGRectMake(kArrowLeftX, noteOffsetY, 60, 60);
					[[[TexturesHolder sharedInstance] getTexture:kTexture_LeftArrow] drawInRect:arrowRect];
			}
			else if( i == kAvailableTrack_Down ) {
					CGRect arrowRect = CGRectMake(kArrowDownX, noteOffsetY, 60, 60);
					[[[TexturesHolder sharedInstance] getTexture:kTexture_DownArrow] drawInRect:arrowRect];
			}
			else if( i == kAvailableTrack_Up ) {
					CGRect arrowRect = CGRectMake(kArrowUpX, noteOffsetY, 60, 60);
					[[[TexturesHolder sharedInstance] getTexture:kTexture_UpArrow] drawInRect:arrowRect];
			}
			else if( i == kAvailableTrack_Right ) { 
					CGRect arrowRect = CGRectMake(kArrowRightX, noteOffsetY, 60, 60);
					[[[TexturesHolder sharedInstance] getTexture:kTexture_RightArrow] drawInRect:arrowRect];					
			}
		}
	}
		
	//Swap the framebuffer
	[glView swapBuffers];
}

@end
