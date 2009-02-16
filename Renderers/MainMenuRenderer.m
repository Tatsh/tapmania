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

#import "QuadTransition.h"

@interface MainMenuRenderer (Animations)
- (void) animateMenu:(MainMenuState)direction; // in or out
@end

@implementation MainMenuRenderer

int mt_PlayButtonY, mt_OptionsButtonY, mt_CreditsButtonY, mt_MenuButtonsX;
int mt_MenuButtonsWidth, mt_MenuButtonsHeight;
int mt_Mass, mt_Gravity;
Texture2D *t_BG, *t_MenuPlay, *t_MenuOptions, *t_MenuCredits;

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
	t_MenuPlay = [[ThemeManager sharedInstance] texture:@"MainMenu ButtonPlay"];
	t_MenuOptions = [[ThemeManager sharedInstance] texture:@"MainMenu ButtonOptions"];
	t_MenuCredits = [[ThemeManager sharedInstance] texture:@"MainMenu ButtonCredits"];
	
	// No item selected by default
	m_nSelectedMenu = -1;
	m_nState = kMainMenuState_Ready;
	
	// Register menu items
	m_pMainMenuItems[kMainMenuItem_Play] = [[MenuItem alloc] initWithTexture:t_MenuPlay andShape:CGRectMake(mt_MenuButtonsX, mt_PlayButtonY, mt_MenuButtonsWidth, mt_MenuButtonsHeight)];
	m_pMainMenuItems[kMainMenuItem_Options] = [[MenuItem alloc] initWithTexture:t_MenuOptions andShape:CGRectMake(mt_MenuButtonsX, mt_OptionsButtonY, mt_MenuButtonsWidth, mt_MenuButtonsHeight)];
	m_pMainMenuItems[kMainMenuItem_Credits] = [[MenuItem alloc] initWithTexture:t_MenuCredits andShape:CGRectMake(mt_MenuButtonsX, mt_CreditsButtonY, mt_MenuButtonsWidth, mt_MenuButtonsHeight)];
	
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
	
	// Add the menu items to the render loop with lower priority
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
			[self animateMenu:kMainMenuState_AnimatingOut];
		} else if(m_nSelectedMenu == kMainMenuItem_Options) {
			TMLog(@"Enter options menu...");
			
			m_nSelectedMenu = -1;
			// TODO
			
		} else if(m_nSelectedMenu == kMainMenuItem_Credits) {
			TMLog(@"Enter credits screen...");
			[self animateMenu:kMainMenuState_AnimatingOut];
		}

	} else if(m_nState == kMainMenuState_Finished) {
		
		if(m_nSelectedMenu == kMainMenuItem_Play) {
			[[TapMania sharedInstance] switchToScreen:[[SongPickerMenuRenderer alloc] init] usingTransition:[QuadTransition class]];

		} else if(m_nSelectedMenu == kMainMenuItem_Options) {
			// [[TapMania sharedInstance] switchToScreen:[[OptionsRenderer alloc] init]];
			
		} else if(m_nSelectedMenu == kMainMenuItem_Credits) {				
			[[TapMania sharedInstance] switchToScreen:[[CreditsRenderer alloc] init] usingTransition:[QuadTransition class]];
		}
		
		m_nState = kMainMenuState_None;	// Do nothing more
	
	} else if(m_nState == kMainMenuState_AnimatingOut) {
		
		Vector* force = [[Vector alloc] initWithX:-mt_Mass * mt_Gravity andY:0.0f];
		
		int i;
		for(i=0; i<kNumMainMenuItems; ++i) {
			
			if(i == kMainMenuItem_Options && m_fAnimationTime < 0.1f) {
				continue;
			} else if(i == kMainMenuItem_Credits && m_fAnimationTime < 0.2f) {
				continue;
			}
			
			m_pVelocity[i].x += force.x / mt_Mass * [fDelta floatValue];
		
			float newXPosition = [m_pMainMenuItems[i] getPosition].x;
			newXPosition += m_pVelocity[i].x * [fDelta floatValue];
		
			float curY = [m_pMainMenuItems[i] getPosition].y;
			[m_pMainMenuItems[i] updatePosition:CGPointMake(newXPosition, curY)];
		
			// Check whether all the items gone off screen already
			if(i == kMainMenuItem_Credits && newXPosition < -mt_MenuButtonsWidth) {
				m_nState = kMainMenuState_Finished; // Allow transition
			}
		}
		
		[force release];
		m_fAnimationTime += [fDelta floatValue];
	}
	
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

- (void) animateMenu:(MainMenuState)direction {
	m_nState = direction;
	m_fAnimationTime = 0.0f;
	
	int i;
	for(i=0; i<kNumMainMenuItems; ++i) {
		if(m_pVelocity[i]) {
			[m_pVelocity[i] release];
		}
		
		m_pVelocity[i] = [[Vector alloc] initWithX:0.0f andY:0.0f];
	}
}

@end
