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
	self = [super initWithShape:CGRectMake(40, 40, 200, 300)];
	if(!self)
		return nil;
	
	// Cache graphics
	t_DialogBG = TEXTURE(@"Common DialogBackground");
	
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
		[[TapMania sharedInstance] deregisterObject:self];
		
		m_bShouldReturn = NO;
	}
}

/* TMGameUIResponder methods */
- (BOOL) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	if([super tmTouchesEnded:touches withEvent:event]) {
		m_bShouldReturn = YES;
		return YES;
	}
	
	return NO;
}

@end
