//
//  SongPickerMenuRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 07.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "SongPickerMenuRenderer.h"

#import "TexturesHolder.h"
#import "TapManiaAppDelegate.h"
#import "SongsDirectoryCache.h"

#import "MainMenuRenderer.h"
#import "SongPlayRenderer.h"

#import "MenuItem.h"

@implementation SongPickerMenuRenderer

- (id) initWithView:(EAGLView*)lGlView {
	self = [super initWithView:lGlView andCapacity:10];
	if(!self)
		return nil;

	// Add all songs as buttons for now
	NSArray* songList = [[SongsDirectoryCache sharedInstance] getSongList];
	for(int i=0; i<[songList count]; i++){
		[self addMenuItemWithTitle:[songList objectAtIndex:i] andHandler:@selector(playGamePress:) onTarget:self];
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
	NSLog(@"Start song...");
	[(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] activateRenderer:[[SongPlayRenderer alloc] initWithView:glView] looping:YES];
}

- (void) backPress:(id)sender {
	NSLog(@"Go to main menu from Play menu...");
	[(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] activateRenderer:[[MainMenuRenderer alloc] initWithView:glView] looping:NO];
}


@end
