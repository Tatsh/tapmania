//
//  DialogRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 8/11/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "DialogRenderer.h"
#import "ThemeManager.h"
#import "Texture2D.h"
#import "TapMania.h"
#import "InputEngine.h"
#import "EAGLView.h"

@implementation DialogRenderer

Texture2D* t_DialogBG;

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	// Cache graphics
	t_DialogBG = [[ThemeManager sharedInstance] texture:@"Common DialogBackground"];
	
	m_bShouldReturn = NO;
	
	return self;
}

/* TMRenderable methods */
- (void) render:(float) fDelta {
	CGRect	bounds = [TapMania sharedInstance].glView.bounds;
	glEnable(GL_BLEND);
	[t_DialogBG drawInRect:bounds];
	glDisable(GL_BLEND);	
}

/* TMLogicUpdater method */
- (void) update:(float)fDelta {
	if(m_bShouldReturn) {
		[[InputEngine sharedInstance] unsubscribe:self];
		[[TapMania sharedInstance] deregisterObject:self];
		
		m_bShouldReturn = NO;
	}
}

/* TMGameUIResponder methods */
- (void) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	m_bShouldReturn = YES;
}

@end
