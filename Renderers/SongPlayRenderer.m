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

#import "TMSong.h"
#import "TMSongOptions.h"


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
