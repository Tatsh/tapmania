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
	self = [super init];
	if(!self)
		return nil;
	
	// No item selected by default
	selectedMenu = -1;
	
	// Register menu items
	mainMenuItems[kMainMenuItem_Play] = [[MenuItem alloc] initWithTexture:kTexture_MainMenuButtonPlay andShape:CGRectMake(60.0f, 200.0f, 200.0f, 40.0f)];
	mainMenuItems[kMainMenuItem_Options] = [[MenuItem alloc] initWithTexture:kTexture_MainMenuButtonOptions andShape:CGRectMake(60.0f, 150.0f, 200.0f, 40.0f)];
	mainMenuItems[kMainMenuItem_Credits] = [[MenuItem alloc] initWithTexture:kTexture_MainMenuButtonCredits andShape:CGRectMake(60.0f, 100.0f, 200.0f, 40.0f)];
	
	return self;
}

- (void) dealloc {
	// Release menu items
	[mainMenuItems[kMainMenuItem_Play] release];
	[mainMenuItems[kMainMenuItem_Options] release];
	[mainMenuItems[kMainMenuItem_Credits] release];
	
	[super dealloc];
}


/* TMTransitionSupport methods */
- (void) setupForTransition {
	// Add the menu items to the render loop with lower priority
	[[RenderEngine sharedInstance] registerRenderer:mainMenuItems[kMainMenuItem_Play] withPriority:kRunLoopPriority_NormalUpper];
	[[RenderEngine sharedInstance] registerRenderer:mainMenuItems[kMainMenuItem_Options] withPriority:kRunLoopPriority_NormalUpper-1];
	[[RenderEngine sharedInstance] registerRenderer:mainMenuItems[kMainMenuItem_Credits] withPriority:kRunLoopPriority_NormalUpper-2];
	
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
	[[[TexturesHolder sharedInstance] getTexture:kTexture_Background] drawInRect:bounds];
	glEnable(GL_BLEND);
	
	// NOTE: Items will be rendered by it self
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
		
		[[LogicEngine sharedInstance] switchToScreen:[[CreditsRenderer alloc] init]];
	}
	
	selectedMenu = -1; // To ensure we are not doing the transition more than once
}

/* TMGameUIResponder methods */
- (void) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
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
}

@end
