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

- (id) init {
	self = [super initWithCapacity:kNumMainMenuItems];
	if(!self)
		return nil;
	
	// No item selected by default
	selectedMenu = -1;
	
	// Register menu items
	[self addMenuItemWithTitle:@"Play TapMania" andHandler:@selector(playGamePress:) onTarget:self];
	[self addMenuItemWithTitle:@"Options" andHandler:@selector(optionsPress:) onTarget:self];
	[self addMenuItemWithTitle:@"Credits" andHandler:@selector(creditsPress:) onTarget:self];
	
	[self publishMenu];
	 
	return self;
}


/* TMRenderable method */
- (void) render:(NSNumber*)fDelta {
	CGRect bounds = [RenderEngine sharedInstance].glView.bounds;
	
	//Draw menu background
	glDisable(GL_BLEND);
	[[[TexturesHolder sharedInstance] getTexture:kTexture_Background] drawInRect:bounds];
	glEnable(GL_BLEND);
}

/* TMLogicUpdater stuff */
- (void) update:(NSNumber*)fDelta {
	if(selectedMenu == -1) 
		return;
	
	if(selectedMenu == kMainMenuItem_Play) {
		NSLog(@"Enter song pick menu...");		
	} else if(selectedMenu == kMainMenuItem_Options) {
		NSLog(@"Enter options menu...");
	} else if(selectedMenu == kMainMenuItem_Credits) {
		NSLog(@"Enter credits screen...");
	/*	
		[[RenderEngine sharedInstance].glView setCurrentContext];
		CreditsRenderer* cRenderer = [[CreditsRenderer alloc] init];
		
		[[RenderEngine sharedInstance] clearRenderers];
		[[LogicEngine sharedInstance] clearLogicUpdaters];
		
		[[RenderEngine sharedInstance] registerRenderer:cRenderer withPriority:kRunLoopPriority_Highest];	
		[[LogicEngine sharedInstance] registerLogicUpdater:cRenderer withPriority:kRunLoopPriority_Highest];	
		*/
	}
	
	selectedMenu = -1;
}

# pragma mark Touch handling
- (void) playGamePress:(id)sender {
	selectedMenu = kMainMenuItem_Play;
}

- (void) optionsPress:(id)sender {
	selectedMenu = kMainMenuItem_Options;
}

- (void) creditsPress:(id)sender {
	selectedMenu = kMainMenuItem_Credits;
}

@end
