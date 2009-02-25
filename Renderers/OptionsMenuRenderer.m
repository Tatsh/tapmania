//
//  OptionsMenuRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TapMania.h"
#import "InputEngine.h"
#import "EAGLView.h"
#import "ThemeManager.h"
#import "Texture2D.h"

#import "MenuItem.h"
#import "ZoomEffect.h"
#import "SlideEffect.h"

#import "QuadTransition.h"

#import "OptionsMenuRenderer.h"
#import "MainMenuRenderer.h"

@interface OptionsMenuRenderer (InputHandling)
- (void) backButtonHit;
@end

@implementation OptionsMenuRenderer

int mt_BackButtonY, mt_MenuButtonsX;
int mt_MenuButtonsWidth, mt_MenuButtonsHeight;
Texture2D *t_BG;

- (id) init {
	self = [super init];
	if(!self)
		return nil;

	// Cache metrics
	mt_BackButtonY = [[ThemeManager sharedInstance] intMetric:@"OptionsMenu BackButtonY"];
	mt_MenuButtonsX = [[ThemeManager sharedInstance] intMetric:@"OptionsMenu ButtonsX"];	
	mt_MenuButtonsWidth = [[ThemeManager sharedInstance] intMetric:@"OptionsMenu ButtonsWidth"];
	mt_MenuButtonsHeight = [[ThemeManager sharedInstance] intMetric:@"OptionsMenu ButtonsHeight"];
	
	// Preload all required graphics
	t_BG = [[ThemeManager sharedInstance] texture:@"OptionsMenu Background"];
	
	// No item selected by default
	m_nSelectedMenu = -1;
	m_nState = kOptionsMenuState_Ready;
	m_dAnimationTime = 0.0;	
	
	// Register menu items
	m_pOptionsMenuItems[kOptionsMenuItem_Back] = 
		[[SlideEffect alloc] initWithRenderable:
			[[ZoomEffect alloc] initWithRenderable:	
				[[MenuItem alloc] initWithTitle:@"Back" andShape:CGRectMake(mt_MenuButtonsX, mt_BackButtonY, mt_MenuButtonsWidth, mt_MenuButtonsHeight)]]];

	[(SlideEffect*)(m_pOptionsMenuItems[kOptionsMenuItem_Back]) destination: CGPointMake(-mt_MenuButtonsWidth, mt_BackButtonY)];
	[(SlideEffect*)(m_pOptionsMenuItems[kOptionsMenuItem_Back]) effectTime: 0.4f];
	
	[m_pOptionsMenuItems[kOptionsMenuItem_Back] setActionHandler:@selector(backButtonHit) receiver:self];
	
	return self;
}

- (void) dealloc {
	// Release menu items
	[m_pOptionsMenuItems[kOptionsMenuItem_Back] release];
	
	[super dealloc];
}

/* TMTransitionSupport methods */
- (void) setupForTransition {
	// Add the menu items to the render loop with lower priority
	[[TapMania sharedInstance] registerObject:m_pOptionsMenuItems[kOptionsMenuItem_Back] withPriority:kRunLoopPriority_NormalUpper];
	
	// Subscribe for input events
	[[InputEngine sharedInstance] subscribe:m_pOptionsMenuItems[kOptionsMenuItem_Back]];
}

- (void) deinitOnTransition {
	// Unsubscribe from input events
	[[InputEngine sharedInstance] unsubscribe:m_pOptionsMenuItems[kOptionsMenuItem_Back]];
	
	// Remove the menu items from the render loop
	[[TapMania sharedInstance] deregisterObject:m_pOptionsMenuItems[kOptionsMenuItem_Back]];
}

- (void)render:(NSNumber*) fDelta {
	CGRect bounds = [TapMania sharedInstance].glView.bounds;
	
	// Draw menu background
	[t_BG drawInRect:bounds];
	
	// NOTE: Items will be rendered by it self	
}	

/* TMLogicUpdater stuff */
- (void) update:(NSNumber*)fDelta {
	if(m_nState == kOptionsMenuState_Ready) {
		
		if(m_nSelectedMenu == kOptionsMenuItem_Back) {
			TMLog(@"Getting back to main menu....");		
			m_nState = kOptionsMenuState_AnimatingOut;
		}
		
	} else if(m_nState == kOptionsMenuState_Finished) {
		
		if(m_nSelectedMenu == kOptionsMenuItem_Back) {
			[[TapMania sharedInstance] switchToScreen:[[MainMenuRenderer alloc] init] usingTransition:[QuadTransition class]];
		}
		
		m_nState = kOptionsMenuState_None;	// Do nothing more
		
	} else if(m_nState == kOptionsMenuState_AnimatingOut) {		
		
		if([(SlideEffect*)m_pOptionsMenuItems[kOptionsMenuItem_Back] isFinished]) {
			m_nState = kMainMenuState_Finished;
			return;
		}
		
		// Start stuff with timeouts
		if(![(SlideEffect*)m_pOptionsMenuItems[kOptionsMenuItem_Back] isFinished] && 
		   ![(SlideEffect*)m_pOptionsMenuItems[kOptionsMenuItem_Back] isTweening])
		{			
			[(SlideEffect*)m_pOptionsMenuItems[kOptionsMenuItem_Back] startTweening];			
		} 
		
		m_dAnimationTime += [fDelta floatValue];
	}
	
}

/* Input handlers */
- (void) backButtonHit {
	m_nSelectedMenu = kOptionsMenuItem_Back;
}

@end
