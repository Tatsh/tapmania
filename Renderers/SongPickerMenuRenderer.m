//
//  SongPickerMenuRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 07.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <syslog.h>

#import "SongPickerMenuRenderer.h"

#import "TMSong.h"
#import "TexturesHolder.h"
#import "TapManiaAppDelegate.h"
#import "SongsDirectoryCache.h"

#import "MainMenuRenderer.h"
#import "SongOptionsRenderer.h"

#import "SongPickerMenuItem.h"

@implementation SongPickerMenuRenderer

- (id) init {
	self = [super init];
	if(!self)
		return nil;

	int i;

	// Add all songs as buttons for now
	NSArray* songList = [[SongsDirectoryCache sharedInstance] getSongList];
		
	for(i=0; i<[songList count]; i++){
		TMSong *song = [songList objectAtIndex:i];
	
		syslog(LOG_DEBUG, "available difficulties:");
		TMSongDifficulty dif = kSongDifficulty_Invalid;
		
		for(; dif < kNumSongDifficulties; dif++) {
			if([song isDifficultyAvailable:dif]) {
	//			syslog(LOG_DEBUG, "%s [%d]", [[TMSong difficultyToString:dif] UTF8String], [song getDifficultyLevel:dif]);
			}
		}		
	}
	
	return self;
}

/* TMTransitionSupport methods */
- (void) setupForTransition {
	// Subscribe for input events
	[[InputEngine sharedInstance] subscribe:self];
}

- (void) deinitOnTransition {
	// Unsubscribe from input events
	[[InputEngine sharedInstance] unsubscribe:self];
}

/* TMRenderable method */
- (void) render:(NSNumber*)fDelta {
	CGRect bounds = [RenderEngine sharedInstance].glView.bounds;
	
	// Draw menu background
	glDisable(GL_BLEND);
	[[[TexturesHolder sharedInstance] getTexture:kTexture_SongSelectionBackground] drawInRect:bounds];
	glEnable(GL_BLEND);
	
	// Positions of the wheel items are fixed

}

/* TMLogicUpdater stuff */
- (void) update:(NSNumber*)fDelta {
	
}

/* TMGameUIResponder methods */
- (void) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	NSLog(@"mhmhmh");
/*
	if([touches count] == 1) {
		UITouch * touch = [touches anyObject];
		CGPoint point = [[RenderEngine sharedInstance].glView convertPointFromViewToOpenGL:
						 [touch locationInView:[RenderEngine sharedInstance].glView]];
		
		if([mainMenuItems[kMainMenuItem_Play] containsPoint:point]){
			selectedMenu = kMainMenuItem_Play;
		} else if([mainMenuItems[kMainMenuItem_Options] containsPoint:point]){
			selectedMenu = kMainMenuItem_Options;
		} else if([mainMenuItems[kMainMenuItem_Credits] containsPoint:point]){
			selectedMenu = kMainMenuItem_Credits;
		}
	}
*/
}


@end
