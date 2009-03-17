//
//  MainMenuRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "MainMenuRenderer.h"
#import "MenuItem.h"
#import "PhysicsUtil.h"

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

#import "ZoomEffect.h"
#import "BlinkEffect.h"
#import "SlideEffect.h"

#import "QuadTransition.h"

@interface MainMenuRenderer (InputHandling)
- (void) playButtonHit;
- (void) optionsButtonHit;
- (void) creditsButtonHit;
@end


@implementation MainMenuRenderer

int mt_PlayButtonY, mt_OptionsButtonY, mt_CreditsButtonY, mt_MenuButtonsX;
int mt_MenuButtonsWidth, mt_MenuButtonsHeight;
int mt_Mass, mt_Gravity;
Texture2D *t_BG;

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
	
	mt_Mass = [[ThemeManager sharedInstance] intMetric:@"MainMenu ButtonMass"];
	mt_Gravity = [[ThemeManager sharedInstance] intMetric:@"MainMenu Gravity"];
	
	// Preload all required graphics
	t_BG = [[ThemeManager sharedInstance] texture:@"MainMenu Background"];
	
	// No item selected by default
	m_nSelectedMenu = -1;
	m_nState = kMainMenuState_Ready;
	m_dAnimationTime = 0.0;
	
	// Register menu items
	m_pMainMenuItems[kMainMenuItem_Play] = 
		[[SlideEffect alloc] initWithRenderable:
			[[ZoomEffect alloc] initWithRenderable:	
				// [[BlinkEffect alloc] initWithRenderable:
					[[MenuItem alloc] initWithTitle:@"Play TapMania" andShape:CGRectMake(mt_MenuButtonsX, mt_PlayButtonY, mt_MenuButtonsWidth, mt_MenuButtonsHeight)]]];							

	m_pMainMenuItems[kMainMenuItem_Options] = 
		[[SlideEffect alloc] initWithRenderable:
			[[ZoomEffect alloc] initWithRenderable:
				[[MenuItem alloc] initWithTitle:@"Options" andShape:CGRectMake(mt_MenuButtonsX, mt_OptionsButtonY, mt_MenuButtonsWidth, mt_MenuButtonsHeight)]]];

	m_pMainMenuItems[kMainMenuItem_Credits] = 	
		[[SlideEffect alloc] initWithRenderable:
			[[ZoomEffect alloc] initWithRenderable:
				[[MenuItem alloc] initWithTitle:@"Credits" andShape:CGRectMake(mt_MenuButtonsX, mt_CreditsButtonY, mt_MenuButtonsWidth, mt_MenuButtonsHeight)]]];

	[(SlideEffect*)(m_pMainMenuItems[kMainMenuItem_Play]) destination: CGPointMake(-mt_MenuButtonsWidth, mt_PlayButtonY)];
	[(SlideEffect*)(m_pMainMenuItems[kMainMenuItem_Options]) destination: CGPointMake(-mt_MenuButtonsWidth, mt_OptionsButtonY)];
	[(SlideEffect*)(m_pMainMenuItems[kMainMenuItem_Credits]) destination: CGPointMake(-mt_MenuButtonsWidth, mt_CreditsButtonY)];

	[(SlideEffect*)(m_pMainMenuItems[kMainMenuItem_Play]) effectTime: 0.4f];
	[(SlideEffect*)(m_pMainMenuItems[kMainMenuItem_Options]) effectTime: 0.4f];
	[(SlideEffect*)(m_pMainMenuItems[kMainMenuItem_Credits]) effectTime: 0.4f];	
	
	[m_pMainMenuItems[kMainMenuItem_Play] setActionHandler:@selector(playButtonHit) receiver:self];
	[m_pMainMenuItems[kMainMenuItem_Options] setActionHandler:@selector(optionsButtonHit) receiver:self];
	[m_pMainMenuItems[kMainMenuItem_Credits] setActionHandler:@selector(creditsButtonHit) receiver:self];

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
	[[InputEngine sharedInstance] subscribe:m_pMainMenuItems[kMainMenuItem_Play]];
	[[InputEngine sharedInstance] subscribe:m_pMainMenuItems[kMainMenuItem_Options]];
	[[InputEngine sharedInstance] subscribe:m_pMainMenuItems[kMainMenuItem_Credits]];	
}

- (void) deinitOnTransition {
	// Unsubscribe from input events
	[[InputEngine sharedInstance] unsubscribe:m_pMainMenuItems[kMainMenuItem_Play]];
	[[InputEngine sharedInstance] unsubscribe:m_pMainMenuItems[kMainMenuItem_Options]];
	[[InputEngine sharedInstance] unsubscribe:m_pMainMenuItems[kMainMenuItem_Credits]];
	
	// Remove the menu items from the render loop
	[[TapMania sharedInstance] deregisterObject:m_pMainMenuItems[kMainMenuItem_Play]];
	[[TapMania sharedInstance] deregisterObject:m_pMainMenuItems[kMainMenuItem_Options]];
	[[TapMania sharedInstance] deregisterObject:m_pMainMenuItems[kMainMenuItem_Credits]];
}

/* TMRenderable method */
- (void) render:(NSNumber*)fDelta {
	CGRect bounds = [TapMania sharedInstance].glView.bounds;
	
	// Draw menu background
	[t_BG drawInRect:bounds];
	
	// NOTE: Items will be rendered by it self
}

/* TMLogicUpdater stuff */
- (void) update:(NSNumber*)fDelta {
	if(m_nState == kMainMenuState_Ready) {
		
		if(m_nSelectedMenu == kMainMenuItem_Play) {
			TMLog(@"Enter song pick menu...");		
			m_nState = kMainMenuState_AnimatingOut;
			
		} else if(m_nSelectedMenu == kMainMenuItem_Options) {
			TMLog(@"Enter options menu...");
			m_nState = kMainMenuState_AnimatingOut;			
			
		} else if(m_nSelectedMenu == kMainMenuItem_Credits) {
			TMLog(@"Enter credits screen...");
			m_nState = kMainMenuState_AnimatingOut;
		}

	} else if(m_nState == kMainMenuState_Finished) {
		
		if(m_nSelectedMenu == kMainMenuItem_Play) {
			[[TapMania sharedInstance] switchToScreen:[[SongPickerMenuRenderer alloc] init] usingTransition:[QuadTransition class]];

		} else if(m_nSelectedMenu == kMainMenuItem_Options) {
			[[TapMania sharedInstance] switchToScreen:[[OptionsMenuRenderer alloc] init]];
			
		} else if(m_nSelectedMenu == kMainMenuItem_Credits) {				
			[[TapMania sharedInstance] switchToScreen:[[CreditsRenderer alloc] init] usingTransition:[QuadTransition class]];
		}
		
		m_nState = kMainMenuState_None;	// Do nothing more
	
	} else if(m_nState == kMainMenuState_AnimatingOut) {		
		
		if([(SlideEffect*)m_pMainMenuItems[kMainMenuItem_Credits] isFinished]) {
			m_nState = kMainMenuState_Finished;
			return;
		}
		
		// Start stuff with timeouts
		if(![(SlideEffect*)m_pMainMenuItems[kMainMenuItem_Play] isFinished] && 
		   ![(SlideEffect*)m_pMainMenuItems[kMainMenuItem_Play] isTweening])
		{			
			[(SlideEffect*)m_pMainMenuItems[kMainMenuItem_Play] startTweening];
			
		} else if(m_dAnimationTime >= 0.1 && ![(SlideEffect*)m_pMainMenuItems[kMainMenuItem_Options] isFinished]
				  && ![(SlideEffect*)m_pMainMenuItems[kMainMenuItem_Options] isTweening]) 
		{			
			[(SlideEffect*)m_pMainMenuItems[kMainMenuItem_Options] startTweening];
			
		} else if(m_dAnimationTime >= 0.2 && ![(SlideEffect*)m_pMainMenuItems[kMainMenuItem_Credits] isFinished]
				  && ![(SlideEffect*)m_pMainMenuItems[kMainMenuItem_Credits] isTweening]) 
		{			
			[(SlideEffect*)m_pMainMenuItems[kMainMenuItem_Credits] startTweening];
		}
						
		m_dAnimationTime += [fDelta floatValue];
	}
	
}

/* Input handlers */
- (void) playButtonHit {
	m_nSelectedMenu = kMainMenuItem_Play;

	// Disable the dispatcher so that we don't mess around with random taps
	[[InputEngine sharedInstance] disableDispatcher];
}

- (void) optionsButtonHit {
	m_nSelectedMenu = kMainMenuItem_Options;
	[[InputEngine sharedInstance] disableDispatcher];
}

- (void) creditsButtonHit {
	m_nSelectedMenu = kMainMenuItem_Credits;
	[[InputEngine sharedInstance] disableDispatcher];
}

@end
