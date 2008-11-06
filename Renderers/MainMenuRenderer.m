//
//  MainMenuRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TapManiaAppDelegate.h"
#import "TexturesHolder.h"
#import "MainMenuRenderer.h"
#import "MenuItem.h"

#import "SongPlayRenderer.h"
#import "OptionsMenuRenderer.h"
#import "CreditsRenderer.h"

@implementation MainMenuRenderer

- (id) initWithView:(EAGLView*)lGlView {
	self = [super initWithView:lGlView andCapacity:kNumMainMenuItems];
	if(!self)
		return nil;
	
	// Register menu items
	[self addMenuItemWithTitle:@"Play TapMania" andHandler:@selector(playGamePress:) onTarget:self];
	[self addMenuItemWithTitle:@"Options" andHandler:@selector(optionsPress:) onTarget:self];
	[self addMenuItemWithTitle:@"Credits" andHandler:@selector(creditsPress:) onTarget:self];
	
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
	NSLog(@"Enter playGame...");
	[(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] activateRenderer:[[SongPlayRenderer alloc] initWithView:glView] noSceneRendering:NO];
}

- (void) optionsPress:(id)sender {
	NSLog(@"Enter options...");	
	[(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] activateRenderer:[[OptionsMenuRenderer alloc] initWithView:glView] noSceneRendering:YES];
}

- (void) creditsPress:(id)sender {
	NSLog(@"Credits page...");
	[(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] activateRenderer:[[CreditsRenderer alloc] initWithView:glView] noSceneRendering:NO];
}

@end
