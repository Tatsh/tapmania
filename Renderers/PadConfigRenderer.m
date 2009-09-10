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
	t_TapNote =			(TapNote*)SKIN_TEXTURE(@"DownTapNote");
		
	// Cache metrics
	mt_ResetButton =	RECT_METRIC(@"PadConfig ResetButton");
	mt_ReceptorRow =	POINT_METRIC(@"SongPlay ReceptorRow");
	mt_LifeBar	=		RECT_METRIC(@"SongPlay LifeBar");

	mt_TapNoteSize =	SIZE_METRIC(@"SongPlay TapNote");
	mt_TapNoteSpacing = INT_METRIC(@"SongPlay TapNote Spacing"); 	
	
	int i;
	for(i=0; i<kNumOfAvailableTracks; ++i) {
		m_oReceptorButtons[i] = CGRectMake(mt_ReceptorRow.x + (mt_TapNoteSize.width + mt_TapNoteSpacing)*i, 
										   mt_ReceptorRow.y, mt_TapNoteSize.width, mt_TapNoteSize.height);
	}		
	
	// Start with no action. means we must select a receptor arrow
	m_nPadConfigAction = kPadConfigAction_None;
	m_pFingerTap = nil;
	
	// Init the receptor row
	m_pReceptorRow = [[ReceptorRow alloc] init];
	
	// Init the lifebar
	m_pLifeBar = [[LifeBar alloc] initWithRect:mt_LifeBar];
	
	// Reset the joyPad to hold currently configured locations
	[[TapMania sharedInstance].joyPad reset];
	
	// Create a reset button
	m_pResetButton = [[ZoomEffect alloc] initWithRenderable:
					  [[MenuItem alloc] initWithTitle:@"Reset" andShape:mt_ResetButton]];
	[m_pResetButton setActionHandler:@selector(resetButtonHit) receiver:self];

	// Add children and subscribe for input
	[[InputEngine sharedInstance] subscribe:self];
	[self pushBackChild:m_pLifeBar];
	[self pushBackChild:m_pReceptorRow];
	[self pushBackControl:m_pResetButton];	
		
	// Remove ads for this time
	[[TapMania sharedInstance] toggleAds:NO];
}

- (void) deinitOnTransition {
	[super deinitOnTransition];
		
	// Unsubscribe from input events
	[[InputEngine sharedInstance] unsubscribe:self];

	// Get ads back to place
	[[TapMania sharedInstance] toggleAds:YES];
}

- (void) dealloc {
	if(m_pFingerTap) {
		[m_pFingerTap release];
	}
	
	[super dealloc];
}

/* TMRenderable methods */
- (void) render:(float) fDelta {
	CGRect	bounds = [TapMania sharedInstance].glView.bounds;
	
	//Draw background
	[t_PadConfigBG drawInRect:bounds];

	// Draw children
	[super render:fDelta];
		
	// Draw the fingertap if any
	if(m_pFingerTap) {
		glEnable(GL_BLEND);
		[t_FingerTap drawAtPoint:CGPointMake(m_pFingerTap.m_fX, m_pFingerTap.m_fY)];
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
		
		// Must also plot a fingertap graphic on current location
		m_pFingerTap = [[TapMania sharedInstance].joyPad getJoyPadButton:m_nSelectedTrack];
		
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
- (void) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	if([touches count] == 1){		
		UITouch* touch = [touches anyObject];
		CGPoint pos = [touch locationInView:[TapMania sharedInstance].glView];
		CGPoint pointGl = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:pos];
		
		int i;
		for(i=0; i<kNumOfAvailableTracks; ++i) {
			if(CGRectContainsPoint(m_oReceptorButtons[i], pointGl)) {
				m_nPadConfigAction = kPadConfigAction_SelectedTrack;
				m_nSelectedTrack = (TMAvailableTracks)i;	// Save the track number we touched
			
				return;
			}
		}
		
		// If none of the receptor arrows was touched
		if(CGRectContainsPoint(mt_LifeBar, pointGl)) {
			m_nPadConfigAction = kPadConfigAction_Exit;
			
		} else if(m_nPadConfigAction == kPadConfigAction_SelectLocation) {			
			TMLog(@"Select location for track %d: x:%f y:%f", m_nSelectedTrack, pointGl.x, pointGl.y);
			[[TapMania sharedInstance].joyPad setJoyPadButton:m_nSelectedTrack onLocation:pointGl];
			
			m_nPadConfigAction = kPadConfigAction_None;
			m_pFingerTap = nil;
		} 
	}		
}

/* Input handlers */
- (void) resetButtonHit {
	if(m_nPadConfigAction == kPadConfigAction_None)
		m_nPadConfigAction = kPadConfigAction_Reset;
}


@end
