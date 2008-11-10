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
#import "TMSongOptions.h"

#import <syslog.h>

#define kArrowsBaseX				25
#define kArrowsBaseY				380
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

- (void) playSong:(TMSong*) song withOptions:(TMSongOptions*) options {
	NSLog(@"Start the song...");
	
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
		
	// Draw the arrow
	arrowPos+=1.0f;
	if(arrowPos > 460.0f) 
		arrowPos = 0.0f;
		
	CGRect arrowRect = CGRectMake(25, arrowPos, 60, 60);
	[[[TexturesHolder sharedInstance] getTexture:kTexture_LeftArrow] drawInRect:arrowRect];
		
	arrowRect = CGRectMake(95, arrowPos+43, 60, 60);
	[[[TexturesHolder sharedInstance] getTexture:kTexture_DownArrow] drawInRect:arrowRect];
		
	arrowRect = CGRectMake(165, arrowPos-30, 60, 60);
	[[[TexturesHolder sharedInstance] getTexture:kTexture_UpArrow] drawInRect:arrowRect];
		
	arrowRect = CGRectMake(235, arrowPos+122, 60, 60);
	[[[TexturesHolder sharedInstance] getTexture:kTexture_RightArrow] drawInRect:arrowRect];
		

	// Test sound
	double elapsedTimeNanos = [TimingUtil getCurrentTime] - playBackStartTime;
//	NSLog(@"Elapsed time since playback start: %f", elapsedTimeNanos);
	
	//Swap the framebuffer
	[glView swapBuffers];
}

@end
