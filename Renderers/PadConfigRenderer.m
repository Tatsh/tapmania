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

#import "TapNote.h"
#import "ReceptorRow.h"
#import "LifeBar.h"

#import "PhysicsUtil.h"

@implementation PadConfigRenderer

Texture2D* t_PadConfigBG;
Texture2D* t_FingerTap;

TapNote* t_TapNote;

int mt_ReceptorRowX, mt_ReceptorRowY;
int mt_TapNoteHeight, mt_TapNoteWidth, mt_TapNoteSpacing;
int mt_LifeBarX, mt_LifeBarY, mt_LifeBarWidth, mt_LifeBarHeight;

/* TMTransitionSupport methods */
- (void) setupForTransition {
	// Cache graphics
	t_PadConfigBG = [[ThemeManager sharedInstance] texture:@"PadConfig Background"];
	t_FingerTap = [[ThemeManager sharedInstance] texture:@"Common FingerTap"];
	t_TapNote = (TapNote*)[[ThemeManager sharedInstance] skinTexture:@"DownTapNote"];
		
	// Cache metrics
	mt_ReceptorRowX = [[ThemeManager sharedInstance] intMetric:@"SongPlay ReceptorRow X"];
	mt_ReceptorRowY = [[ThemeManager sharedInstance] intMetric:@"SongPlay ReceptorRow Y"];
	
	mt_TapNoteWidth = [[ThemeManager sharedInstance] intMetric:@"SongPlay TapNote Width"];
	mt_TapNoteHeight = [[ThemeManager sharedInstance] intMetric:@"SongPlay TapNote Height"];
	mt_TapNoteSpacing = [[ThemeManager sharedInstance] intMetric:@"SongPlay TapNote Spacing"]; 
	
	mt_LifeBarX =		[[ThemeManager sharedInstance] intMetric:@"SongPlay LifeBar X"];
	mt_LifeBarY =		[[ThemeManager sharedInstance] intMetric:@"SongPlay LifeBar Y"];
	mt_LifeBarWidth =	[[ThemeManager sharedInstance] intMetric:@"SongPlay LifeBar Width"];
	mt_LifeBarHeight =	[[ThemeManager sharedInstance] intMetric:@"SongPlay LifeBar Height"];
	
	int i;
	for(i=0; i<kNumOfAvailableTracks; ++i) {
		m_oReceptorButtons[i] = CGRectMake(mt_ReceptorRowX + (mt_TapNoteWidth+mt_TapNoteSpacing)*i, 
										   mt_ReceptorRowY, mt_TapNoteWidth, mt_TapNoteHeight);
	}		
	
	// Start with no action. means we must select a receptor arrow
	m_nPadConfigAction = kPadConfigAction_None;
	m_pFingerTap = nil;
	
	// Init the receptor row
	m_pReceptorRow = [[ReceptorRow alloc] init];
	
	// Init the lifebar
	m_pLifeBar = [[LifeBar alloc] initWithRect:CGRectMake(mt_LifeBarX, mt_LifeBarY, mt_LifeBarWidth, mt_LifeBarHeight)];
	
	// Reset the joyPad to hold currently configured locations
	[[TapMania sharedInstance].joyPad reset];
	
	// Subscribe for input events
	[[InputEngine sharedInstance] subscribe:self];
}

- (void) deinitOnTransition {
	// Unsubscribe from input events
	[[InputEngine sharedInstance] unsubscribe:self];
}

- (void) dealloc {
	[m_pReceptorRow release];
	[m_pLifeBar release];
	
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

	// Draw the lifebar (exit button)
	[m_pLifeBar render:fDelta];
	
	// Draw the receptor row
	[m_pReceptorRow render:fDelta];
	
	// Draw the fingertap if any
	if(m_pFingerTap) {
		glEnable(GL_BLEND);
		[t_FingerTap drawAtPoint:CGPointMake(m_pFingerTap.m_fX, m_pFingerTap.m_fY)];
		glDisable(GL_BLEND);
	}
}

/* TMLogicUpdater method */
- (void) update:(float)fDelta {
	
	if(m_nPadConfigAction == kPadConfigAction_Exit) {
		// Exit to options menu
		[[TapMania sharedInstance] switchToScreen:[[OptionsMenuRenderer alloc] init] usingTransition:[QuadTransition class]];
		
		m_nPadConfigAction = kPadConfigAction_None;
	}
	
	if(m_nPadConfigAction == kPadConfigAction_SelectedTrack) {
		// Should explode the selected track
		[m_pReceptorRow explodeBright:m_nSelectedTrack];
		m_nPadConfigAction = kPadConfigAction_SelectLocation;	// Must select a location now
		
		// Must also plot a fingertap graphic on current location
		m_pFingerTap = [[TapMania sharedInstance].joyPad getJoyPadButton:m_nSelectedTrack];
		
	} else if(m_nPadConfigAction == kPadConfigAction_SelectLocation) {
		// Must light the selected receptor while user decides
		[m_pReceptorRow explodeBright:m_nSelectedTrack];
	}

	[m_pReceptorRow update:fDelta];
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
				m_nSelectedTrack = i;	// Save the track number we touched
			
				return;
			}
		}
		
		// If none of the receptor arrows was touched
		if(CGRectContainsPoint(CGRectMake(mt_LifeBarX, mt_LifeBarY, mt_LifeBarWidth, mt_LifeBarHeight), pointGl)) {
			m_nPadConfigAction = kPadConfigAction_Exit;
			
		} else if(m_nPadConfigAction == kPadConfigAction_SelectLocation) {			
			TMLog(@"Select location for track %d: x:%f y:%f", m_nSelectedTrack, pointGl.x, pointGl.y);
			[[TapMania sharedInstance].joyPad setJoyPadButton:m_nSelectedTrack onLocation:pointGl];
			
			m_nPadConfigAction = kPadConfigAction_None;
			m_pFingerTap = nil;
		}
	}		
}

@end
