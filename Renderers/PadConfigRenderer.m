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

@implementation PadConfigRenderer

Texture2D* t_PadConfigBG;

- (void) dealloc {
	[super dealloc];
}

/* TMTransitionSupport methods */
- (void) setupForTransition {
	// Cache graphics
	t_PadConfigBG = [[ThemeManager sharedInstance] texture:@"PadConfig Background"];
		
	// Subscribe for input events
	[[InputEngine sharedInstance] subscribe:self];
}

- (void) deinitOnTransition {
	// Unsubscribe from input events
	[[InputEngine sharedInstance] unsubscribe:self];
}

/* TMRenderable methods */
- (void) render:(float) fDelta {
	CGRect	bounds = [TapMania sharedInstance].glView.bounds;
	
	//Draw background
	[t_PadConfigBG drawInRect:bounds];
}

/* TMLogicUpdater method */
- (void) update:(float)fDelta {
}

/* TMGameUIResponder methods */
- (void) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
}

@end
