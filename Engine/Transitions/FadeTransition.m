//
//  FadeTransition.m
//  TapMania
//
//  Created by Alex Kremer on 11.02.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "FadeTransition.h"
#import "TapMania.h"
#import "ThemeManager.h"
#import "EAGLView.h"

@implementation FadeTransition

Texture2D* t_Blank;

- (id) initFromScreen:(AbstractRenderer*)fromScreen toScreen:(AbstractRenderer*)toScreen {
	self = [super initFromScreen:fromScreen toScreen:toScreen];
	if (!self)
		return nil;
	
	// Cache graphics
	t_Blank = [[ThemeManager sharedInstance] texture:@"Blank"];	
	m_dTransitionPosition = 0.0f;
	
	return self;
}


// TMRenderable stuff
- (void)render:(NSNumber*)fDelta {	
	CGRect	bounds = [TapMania sharedInstance].glView.bounds;

	// TODO: fix this code so that it uses a transparent image and so that these calls to glTexEnvi and glBlendFunc are done only once
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	glBlendFunc(GL_DST_COLOR, GL_ONE_MINUS_SRC_ALPHA);

	glColor4f(m_dTransitionPosition, m_dTransitionPosition, m_dTransitionPosition, m_dTransitionPosition);
	[t_Blank drawInRect: bounds];
	
	glColor4f(1, 1, 1, 1);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
}

- (BOOL) updateTransitionIn:(float)fDelta { 
	[super updateTransitionIn:fDelta];
	
	float transDelta = fDelta / kDefaultTransitionInTime;
	m_dTransitionPosition += transDelta;
	
	if(m_dTransitionPosition >= 1.0f) {
		m_dTransitionPosition = 1.0f;

		return YES; // Ready
	}
	
	return NO; // Busy
}

- (BOOL) updateTransitionOut:(float)fDelta { 
	[super updateTransitionOut:fDelta];

	float transDelta = fDelta / kDefaultTransitionOutTime;
	m_dTransitionPosition -= transDelta;
	
	if(m_dTransitionPosition <= 0.0f) {
		m_dTransitionPosition = 0.0f;
		
		return YES; // Ready
	}
	
	return NO; // Busy
}

@end
