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
#import "MenuItem.h"

#import "TapNote.h"
#import "ReceptorRow.h"
#import "LifeBar.h"

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
	
	// Init the receptor row
	m_pReceptorRow = [[ReceptorRow alloc] init];
	
	// Init the lifebar
	m_pLifeBar = [[LifeBar alloc] initWithRect:CGRectMake(mt_LifeBarX, mt_LifeBarY, mt_LifeBarWidth, mt_LifeBarHeight)];
	
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
}

/* TMLogicUpdater method */
- (void) update:(float)fDelta {
	
	if(m_nPadConfigAction == kPadConfigAction_SelectedTrack) {
		// Should explode the selected track
		[m_pReceptorRow explodeBright:m_nSelectedTrack];
		m_nPadConfigAction = kPadConfigAction_SelectLocation;	// Must select a location now
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
			} else if(CGRectContainsPoint(CGRectMake(mt_LifeBarX, mt_LifeBarY, mt_LifeBarWidth, mt_LifeBarHeight), pointGl)) {
				TMLog(@"EXIT!");
			} else if(m_nPadConfigAction == kPadConfigAction_SelectLocation && m_nSelectedTrack == i) {
				TMLog(@"Select location for track %d: x:%f y:%f", i, pointGl.x, pointGl.y);
			}
		}
	}		
}

@end
