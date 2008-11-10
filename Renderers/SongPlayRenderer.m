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
#import "SongsDirectoryCache.h"
#import "DWIParser.h"

#import "TMSong.h"
#import "TMSongOptions.h"

#import <syslog.h>

#define kArrowsBaseX				25
#define kArrowsBaseY				380
#define kArrowsBaseWidth			270
#define kArrowsBaseHeight			60


@interface SongPlayRenderer (Private)
- (void) playSong:(TMSong*) song withOptions:(TMSongOptions*) options;
@end


@implementation SongPlayRenderer

- (id) initWithView:(EAGLView*)lGlView {
	self = [super initWithView:lGlView];
	if(!self)
		return nil;
	
	// Testing
	arrowPos = 0.0f;

	/*
	
	NSLog(@"play %@", trk);
	SoundEngine_LoadBackgroundMusicTrack([trk UTF8String], YES, NO);
	
	SoundEngine_StartBackgroundMusic();
	*/

	// Try to parse the dwi file	
	NSString* dwiFile = [NSString stringWithFormat:@"%@/%@", [[SongsDirectoryCache sharedInstance] getSongsPath], @"a/a.dwi"];
	TMSong *song = [DWIParser parseFromFile:dwiFile];

	syslog(LOG_DEBUG, "Got song info: %s/%s/%f", [song.title UTF8String], [song.artist UTF8String], song.bpm );
	syslog(LOG_DEBUG, "available difficulties:");
	TMSongDifficulty dif = kSongDifficulty_Invalid;

	for(; dif < kNumSongDifficulties; dif++) {
		if([song isDifficultyAvailable:dif]) {
			syslog(LOG_DEBUG, "%s [%d]", [[TMSong difficultyToString:dif] UTF8String], [song getDifficultyLevel:dif]);
		}
	}

	// Show joyPad
	[(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] showJoyPad];
	
	return self;
}

- (void) playSong:(TMSong*) song withOptions:(TMSongOptions*) options {
	NSLog(@"Start the song...");
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
	arrowPos+=10.0f;
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
		
	// Create and show the status text
	/*
		Texture2D* _statusTexture = [[Texture2D alloc] initWithString:[NSString stringWithFormat:@"[%s %s %s %s]", [joyPad getStateForButton:kJoyButtonLeft]?"#":"_", 
										[joyPad getStateForButton:kJoyButtonDown]?"#":"_",[joyPad getStateForButton:kJoyButtonUp]?"#":"_",[joyPad getStateForButton:kJoyButtonRight]?"#":"_"] 
														   dimensions:CGSizeMake(256, 32) alignment:UITextAlignmentCenter fontName:kFontName fontSize:kStatusFontSize];
		
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		[_statusTexture drawAtPoint:CGPointMake(bounds.size.width / 2, bounds.size.height / 2)];
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	 */
	
	//Swap the framebuffer
	[glView swapBuffers];
}

@end
