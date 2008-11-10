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

@implementation SongPlayRenderer

- (id) initWithView:(EAGLView*)lGlView {
	self = [super initWithView:lGlView];
	if(!self)
		return nil;
	
	// Testing
	arrowPos = 0.0f;

	// Show joyPad
	[(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] showJoyPad];
	
	return self;
}

- (void) playSong:(TMSong*) lSong onDifficulty:(TMSongDifficulty)difficulty withOptions:(TMSongOptions*) options {
	NSLog(@"Start the song...");
	
	song = lSong;
	steps = [song getStepsForDifficulty:difficulty];
	
	bpmSpeed = song.bpm/50.0f;
	fullScreenTime = 480.0f/bpmSpeed/60.0f;	// Full screen is 480px with rate of 60 frames per second
	
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
	int i;
	
	for(i=0; i<kNumOfAvailableTracks; i++) {
		
		// Search in this track for items starting at index:
		int startIndex = trackPos[i];
		int j;
		
		for(j=startIndex; j<[steps getNotesCountForTrack:i] ; j++) {
			TMNote* note = [steps getNote:j fromTrack:i];

			if(note.time <= elapsedTime) {
				// Found a note which is out of screen now
				++trackPos[i];
				
				continue; // Skip this note
			}
			
			// Ok, hit a note which is out of scope
			if(note.time > searchTillTime){			
				break;
			}
			
			// If the time is inside the search region - calculate the Y position on screen and draw the note
			double noteOffsetY = 480.0f - ( 480.0f/fullScreenTime * (note.time-elapsedTime) );
			
			if( i == kAvailableTrack_Left ) {
					CGRect arrowRect = CGRectMake(30, noteOffsetY, 60, 60);
					[[[TexturesHolder sharedInstance] getTexture:kTexture_LeftArrow] drawInRect:arrowRect];
			}
			else if( i == kAvailableTrack_Down ) {
					CGRect arrowRect = CGRectMake(100, noteOffsetY, 60, 60);
					[[[TexturesHolder sharedInstance] getTexture:kTexture_DownArrow] drawInRect:arrowRect];
			}
			else if( i == kAvailableTrack_Up ) {
					CGRect arrowRect = CGRectMake(165, noteOffsetY, 60, 60);
					[[[TexturesHolder sharedInstance] getTexture:kTexture_UpArrow] drawInRect:arrowRect];
			}
			else if( i == kAvailableTrack_Right ) { 
					CGRect arrowRect = CGRectMake(240, noteOffsetY, 60, 60);
					[[[TexturesHolder sharedInstance] getTexture:kTexture_RightArrow] drawInRect:arrowRect];					
			}
		}
	}
		
	//Swap the framebuffer
	[glView swapBuffers];
}

@end
