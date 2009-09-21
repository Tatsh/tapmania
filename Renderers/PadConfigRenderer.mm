//
//  PadConfigRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 6/16/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "PadConfigRenderer.h"
#import "Texture2D.h"
#import "InputEngine.h"
#import "ThemeManager.h"

#import "EAGLView.h"
#import "TapMania.h"
#import "MainMenuRenderer.h"
#import "OptionsMenuRenderer.h"
#import "QuadTransition.h"
#import "MenuItem.h"
#import "ZoomEffect.h"

#import "TapNote.h"
#import "ReceptorRow.h"
#import "LifeBar.h"
#import "JoyPad.h"

#import "PhysicsUtil.h"

@interface PadConfigRenderer (InputHandling)
- (void) resetButtonHit;
@end

@implementation PadConfigRenderer

/* TMTransitionSupport methods */
- (void) setupForTransition {
	[super setupForTransition];
	
	// Cache graphics
	t_PadConfigBG =		TEXTURE(@"PadConfig Background");
	t_FingerTap =		TEXTURE(@"Common FingerTap");
	t_FingerTapBright = TEXTURE(@"Common FingerTapBright");
	t_TapNote =			(TapNote*)SKIN_TEXTURE(@"DownTapNote");
		
	// Cache metrics
	mt_ResetButton =	RECT_METRIC(@"PadConfig ResetButton");
	mt_LifeBar	=		RECT_METRIC(@"SongPlay LifeBar");
	
	// Reset the joyPad to hold currently configured locations
	[[TapMania sharedInstance].joyPad reset];
	
	int i;
	for(i=0; i<kNumOfAvailableTracks; ++i) {
		mt_ReceptorButtons[i] =	RECT_SKIN_METRIC(([NSString stringWithFormat:@"ReceptorRow %d", i]));
		m_pFingerTap[i] = [[TapMania sharedInstance].joyPad getJoyPadButton:(JPButton)i];
	}
	
	// Start with no action. means we must select a receptor arrow
	m_nPadConfigAction = kPadConfigAction_None;
	
	// Init the receptor row
	m_pReceptorRow = [[ReceptorRow alloc] init];
	
	// Init the lifebar
	m_pLifeBar = [[LifeBar alloc] initWithRect:mt_LifeBar];
		
	// Create a reset button
	m_pResetButton = [[ZoomEffect alloc] initWithRenderable:
					  [[MenuItem alloc] initWithTitle:@"Reset" andShape:mt_ResetButton]];
	[m_pResetButton setActionHandler:@selector(resetButtonHit) receiver:self];

	// Add children
	[self pushBackChild:m_pLifeBar];
	[self pushBackChild:m_pReceptorRow];
	[self pushBackControl:m_pResetButton];	
		
	// Remove ads for this time
	[[TapMania sharedInstance] toggleAds:NO];
}

- (void) deinitOnTransition {
	[super deinitOnTransition];
		
	// Get ads back to place
	[[TapMania sharedInstance] toggleAds:YES];
}

/* TMRenderable methods */
- (void) render:(float) fDelta {
	CGRect	bounds = [TapMania sharedInstance].glView.bounds;
	
	//Draw background
	[t_PadConfigBG drawInRect:bounds];

	// Draw children
	[super render:fDelta];
		
	// Draw the fingertaps
	for(int i=0; i<kNumOfAvailableTracks; ++i) {
		glEnable(GL_BLEND);
		if(i==m_nSelectedTrack && m_nPadConfigAction == kPadConfigAction_SelectLocation) {
			[t_FingerTapBright drawAtPoint:CGPointMake(m_pFingerTap[i].m_fX, m_pFingerTap[i].m_fY)];
		} else {
			[t_FingerTap drawAtPoint:CGPointMake(m_pFingerTap[i].m_fX, m_pFingerTap[i].m_fY)];
		}
		glDisable(GL_BLEND);
	}
}

/* TMLogicUpdater method */
- (void) update:(float)fDelta {	

	// Show the reset button if no track is selected
	if(m_nPadConfigAction == kPadConfigAction_None) {
		[m_pResetButton show];	
	}
	
	if(m_nPadConfigAction == kPadConfigAction_Exit) {
		// Exit to options menu
		[[TapMania sharedInstance] switchToScreen:[[OptionsMenuRenderer alloc] init] usingTransition:[QuadTransition class]];
		
		m_nPadConfigAction = kPadConfigAction_None;
	}
	
	if(m_nPadConfigAction == kPadConfigAction_SelectedTrack) {
		// Should explode the selected track
		[m_pReceptorRow explodeBright:m_nSelectedTrack];
		[m_pResetButton hide];
		
		m_nPadConfigAction = kPadConfigAction_SelectLocation;	// Must select a location now
				
	} else if(m_nPadConfigAction == kPadConfigAction_SelectLocation) {
		// Must light the selected receptor while user decides
		[m_pReceptorRow explodeBright:m_nSelectedTrack];
		
	} else if(m_nPadConfigAction == kPadConfigAction_Reset) {
		// Reset the pad to default values
		TMLog(@"Reset pad");
		[[TapMania sharedInstance].joyPad resetToDefault];
		m_nPadConfigAction = kPadConfigAction_None;
	}

	[super update:fDelta];
}

/* TMGameUIResponder methods */
- (BOOL) tmTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	if(m_nPadConfigAction != kPadConfigAction_SelectLocation)
		return YES;	// We handled the touch.. just don't bother with it
	
	if([touches count] == 1){		
		UITouch* touch = [touches anyObject];
		CGPoint pos = [touch locationInView:[TapMania sharedInstance].glView];
		CGPoint pointGl = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:pos];
					
		m_pFingerTap[m_nSelectedTrack].m_fX = pointGl.x;
		m_pFingerTap[m_nSelectedTrack].m_fY = pointGl.y;
	}		
	
	return YES;
}

- (BOOL) tmTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	return [self tmTouchesBegan:touches withEvent:event];
}

- (BOOL) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	if([touches count] == 1){		
		UITouch* touch = [touches anyObject];
		CGPoint pos = [touch locationInView:[TapMania sharedInstance].glView];
		CGPoint pointGl = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:pos];
		
		int i;
		for(i=0; i<kNumOfAvailableTracks; ++i) {
			if(CGRectContainsPoint(mt_ReceptorButtons[i], pointGl)) {
				m_nPadConfigAction = kPadConfigAction_SelectedTrack;
				m_nSelectedTrack = (TMAvailableTracks)i;	// Save the track number we touched
			
				return YES;
			}
		}
		
		// If none of the receptor arrows was touched
		if(CGRectContainsPoint(mt_LifeBar, pointGl)) {
			m_nPadConfigAction = kPadConfigAction_Exit;
			
		} else if(m_nPadConfigAction == kPadConfigAction_SelectLocation) {			
			TMLog(@"Select location for track %d: x:%f y:%f", m_nSelectedTrack, pointGl.x, pointGl.y);
			[[TapMania sharedInstance].joyPad setJoyPadButton:(JPButton)m_nSelectedTrack onLocation:pointGl];
			
			m_nPadConfigAction = kPadConfigAction_None;
		} 
	}		
	
	return YES;
}

/* Input handlers */
- (void) resetButtonHit {
	if(m_nPadConfigAction == kPadConfigAction_None)
		m_nPadConfigAction = kPadConfigAction_Reset;
}


@end
