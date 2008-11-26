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

#import "SongPickerMenuRenderer.h"
#import "OptionsMenuRenderer.h"
#import "CreditsRenderer.h"



#import "TMRunLoop.h"
#import "TMRenderable.h"
#import "TMLogicUpdater.h"


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


/* TMRenderable method */
- (void) render:(float)fDelta {
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
	NSLog(@"Enter song pick menu...");
	[(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] registerRenderer:[[SongPickerMenuRenderer alloc] initWithView:glView] withPriority:NO];
}

- (void) optionsPress:(id)sender {
	NSLog(@"Enter options...");	
	[(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] registerRenderer:[[OptionsMenuRenderer alloc] initWithView:glView] withPriority:NO];
}

- (void) creditsPress:(id)sender {
	NSLog(@"Credits page...");
}

@end
