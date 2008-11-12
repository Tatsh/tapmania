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

@interface SongPickerMenuRenderer (Private)
- (void) addMenuItemWithSong:(TMSong*) song andHandler:(SEL)sel onTarget:(id)target;
@end


@implementation SongPickerMenuRenderer

- (id) initWithView:(EAGLView*)lGlView {
	self = [super initWithView:lGlView andCapacity:10];
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
				syslog(LOG_DEBUG, "%s [%d]", [[TMSong difficultyToString:dif] UTF8String], [song getDifficultyLevel:dif]);
			}
		}		
		
		[self addMenuItemWithSong:song andHandler:@selector(playGamePress:) onTarget:self];
	}
	
	// Add back button
	[self enableBackButton]; // Handled by 'backPress:'
	[self publishMenu];
		
	return self;
}

- (void)renderScene {
	CGRect				bounds = [glView bounds];
	
	//Draw background
	glDisable(GL_BLEND);
	[[[TexturesHolder sharedInstance] getTexture:kTexture_Background] drawInRect:bounds];
	glEnable(GL_BLEND);
	
	//Swap the framebuffer
	[glView swapBuffers];
}	

# pragma mark Touch handling
- (void) playGamePress:(id)sender {
	SongPickerMenuItem* menuItem = (SongPickerMenuItem*)sender;
	TMSong* song = menuItem.song;

	NSLog(@"Go to song options from Play menu...");
	[(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] activateRenderer:[[SongOptionsRenderer alloc] initWithView:glView andSong:song] looping:NO];
}

- (void) backPress:(id)sender {
	NSLog(@"Go to main menu from Play menu...");
	[(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] activateRenderer:[[MainMenuRenderer alloc] initWithView:glView] looping:NO];
}


# pragma mark Private stuff
- (void) addMenuItemWithSong:(TMSong*) lSong andHandler:(SEL)sel onTarget:(id)target {
	MenuItem* newItem = [[SongPickerMenuItem alloc] initWithSong:lSong];
	
	// Register callback
	[newItem addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
	
	[_menuElements addObject:newItem];
}

@end
