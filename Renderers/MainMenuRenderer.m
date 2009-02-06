//
//  MainMenuRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TexturesHolder.h"
#import "MainMenuRenderer.h"
#import "MenuItem.h"

#import "SongPickerMenuRenderer.h"
#import "OptionsMenuRenderer.h"
#import "CreditsRenderer.h"

#import "TMRunLoop.h"
#import "TMRenderable.h"
#import "TMLogicUpdater.h"

#import "EAGLView.h"
#import "InputEngine.h"
#import "TapMania.h"
#import "ThemeManager.h"
#import "Texture2D.h"

#import <syslog.h>

static int mt_PlayButtonY, mt_OptionsButtonY, mt_CreditsButtonY, mt_MenuButtonsX;
static int mt_MenuButtonsWidth, mt_MenuButtonsHeight;

static Texture2D* bg;

@implementation MainMenuRenderer

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	// Cache metrics
	mt_PlayButtonY = [[ThemeManager sharedInstance] intMetric:@"MainMenu PlayButtonY"];
	mt_OptionsButtonY = [[ThemeManager sharedInstance] intMetric:@"MainMenu OptionsButtonY"];
	mt_CreditsButtonY = [[ThemeManager sharedInstance] intMetric:@"MainMenu CreditsButtonY"];
	mt_MenuButtonsX = [[ThemeManager sharedInstance] intMetric:@"MainMenu ButtonsX"];	
	mt_MenuButtonsWidth = [[ThemeManager sharedInstance] intMetric:@"MainMenu ButtonsWidth"];
	mt_MenuButtonsHeight = [[ThemeManager sharedInstance] intMetric:@"MainMenu ButtonsHeight"];
	
	// Preload all required graphics
	bg = [[[ThemeManager sharedInstance].theme getResource:@"MainMenu Background"] resource];
	
	// No item selected by default
	m_nSelectedMenu = -1;
	
	// Register menu items
	m_pMainMenuItems[kMainMenuItem_Play] = [[MenuItem alloc] initWithTexture:kTexture_MainMenuButtonPlay andShape:CGRectMake(mt_MenuButtonsX, mt_PlayButtonY, mt_MenuButtonsWidth, mt_MenuButtonsHeight)];
	m_pMainMenuItems[kMainMenuItem_Options] = [[MenuItem alloc] initWithTexture:kTexture_MainMenuButtonOptions andShape:CGRectMake(mt_MenuButtonsX, mt_OptionsButtonY, mt_MenuButtonsWidth, mt_MenuButtonsHeight)];
	m_pMainMenuItems[kMainMenuItem_Credits] = [[MenuItem alloc] initWithTexture:kTexture_MainMenuButtonCredits andShape:CGRectMake(mt_MenuButtonsX, mt_CreditsButtonY, mt_MenuButtonsWidth, mt_MenuButtonsHeight)];
	
	return self;
}

- (void) dealloc {
	// Release menu items
	[m_pMainMenuItems[kMainMenuItem_Play] release];
	[m_pMainMenuItems[kMainMenuItem_Options] release];
	[m_pMainMenuItems[kMainMenuItem_Credits] release];
	
	[super dealloc];
}


/* TMTransitionSupport methods */
- (void) setupForTransition {
	// Add the menu items to the render loop with lower priority
	[[TapMania sharedInstance] registerObject:m_pMainMenuItems[kMainMenuItem_Play] withPriority:kRunLoopPriority_NormalUpper];
	[[TapMania sharedInstance] registerObject:m_pMainMenuItems[kMainMenuItem_Options] withPriority:kRunLoopPriority_NormalUpper-1];
	[[TapMania sharedInstance] registerObject:m_pMainMenuItems[kMainMenuItem_Credits] withPriority:kRunLoopPriority_NormalUpper-2];
	
	// Subscribe for input events
	[[InputEngine sharedInstance] subscribe:self];
}

- (void) deinitOnTransition {
	// Unsubscribe from input events
	[[InputEngine sharedInstance] unsubscribe:self];
}

/* TMRenderable method */
- (void) render:(NSNumber*)fDelta {
	CGRect bounds = [TapMania sharedInstance].glView.bounds;
	
	// Draw menu background
	glDisable(GL_BLEND);
	// [[[TexturesHolder sharedInstance] getTexture:kTexture_MainMenuBackground] drawInRect:bounds];
	[bg drawInRect:bounds];
	glEnable(GL_BLEND);
	
	// NOTE: Items will be rendered by it self
}

/* TMLogicUpdater stuff */
- (void) update:(NSNumber*)fDelta {
	if(m_nSelectedMenu == -1) 
		return;
	
	if(m_nSelectedMenu == kMainMenuItem_Play) {
		NSLog(@"Enter song pick menu...");		
		
		[[TapMania sharedInstance] switchToScreen:[[SongPickerMenuRenderer alloc] init]];
	} else if(m_nSelectedMenu == kMainMenuItem_Options) {
		NSLog(@"Enter options menu...");
		
		// [[TapMania sharedInstance] switchToScreen:[[OptionsRenderer alloc] init]];
	} else if(m_nSelectedMenu == kMainMenuItem_Credits) {
		NSLog(@"Enter credits screen...");
		
		[[TapMania sharedInstance] switchToScreen:[[CreditsRenderer alloc] init]];
	}
	
	m_nSelectedMenu = -1; // To ensure we are not doing the transition more than once
}

/* TMGameUIResponder methods */
- (void) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	if([touches count] == 1) {
		UITouch * touch = [touches anyObject];
		CGPoint point = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:
							[touch locationInView:[TapMania sharedInstance].glView]];
	
		if([m_pMainMenuItems[kMainMenuItem_Play] containsPoint:point]){
			m_nSelectedMenu = kMainMenuItem_Play;
		} else if([m_pMainMenuItems[kMainMenuItem_Options] containsPoint:point]){
			m_nSelectedMenu = kMainMenuItem_Options;
		} else if([m_pMainMenuItems[kMainMenuItem_Credits] containsPoint:point]){
			m_nSelectedMenu = kMainMenuItem_Credits;
		}
	}
}

@end
