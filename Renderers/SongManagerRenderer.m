//
//  SongManagerRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 06.08.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "SongManagerRenderer.h"

#import "Texture2D.h"

#import "InputEngine.h"
#import "TapMania.h"
#import "ThemeManager.h"
#import "EAGLView.h"
#import "WebServer.h"

#import "QuadTransition.h"
#import "OptionsMenuRenderer.h"

@implementation SongManagerRenderer

Texture2D* t_SongManagerBG;

int mt_UrlX, mt_UrlY;

/* TMTransitionSupport methods */
- (void) setupForTransition {
	// Cache graphics
	t_SongManagerBG = [[ThemeManager sharedInstance] texture:@"SongManager Background"];
	
	// Cache metrics
	mt_UrlX = [[ThemeManager sharedInstance] intMetric:@"SongManager UrlX"];
	mt_UrlY = [[ThemeManager sharedInstance] intMetric:@"SongManager UrlY"];
	
	// Start with no action
	m_nAction = kSongManagerAction_None;
		
	// Subscribe for input events
	[[InputEngine sharedInstance] subscribe:self];
	
	// Now start the web server
	[[WebServer sharedInstance] start];
	
	m_pServerUrl = [[Texture2D alloc] initWithString:[WebServer sharedInstance].m_sCurrentServerURL 
										  dimensions:CGSizeMake(320, 60) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:18];
	
	m_nAction = kSongManagerAction_Running;
}

- (void) deinitOnTransition {
	// Unsubscribe from input events
	[[InputEngine sharedInstance] unsubscribe:self];
	
	[[WebServer sharedInstance] stop];
}

- (void) dealloc {	
	[m_pServerUrl release];
	
	[super dealloc];
}

/* TMRenderable methods */
- (void) render:(float) fDelta {
	CGRect	bounds = [TapMania sharedInstance].glView.bounds;
	
	//Draw background
	[t_SongManagerBG drawInRect:bounds];

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	[m_pServerUrl drawAtPoint:CGPointMake(mt_UrlX, mt_UrlY)];	
	
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_BLEND);
}

/* TMLogicUpdater method */
- (void) update:(float)fDelta {	
	if(m_nAction == kSongManagerAction_Exit) {
		// Exit to options menu
		[[TapMania sharedInstance] switchToScreen:[[OptionsMenuRenderer alloc] init] usingTransition:[QuadTransition class]];
		
		m_nAction = kSongManagerAction_None;
	}
}

/* TMGameUIResponder methods */
- (void) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	if([touches count] == 1 && m_nAction != kSongManagerAction_None){		
		// Exit
		m_nAction = kSongManagerAction_Exit;
	}		
}

@end