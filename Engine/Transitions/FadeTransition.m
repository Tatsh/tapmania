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

- (id) initFromScreen:(AbstractRenderer*)fromScreen toScreen:(AbstractRenderer*)toScreen {
	self = [super initFromScreen:fromScreen toScreen:toScreen];
	if (!self)
		return nil;
	
	m_fTransitionPosition = 0.0f;
	
	return self;
}


// TMRenderable stuff
- (void)render:(NSNumber*)fDelta {	
	CGRect	rect = [TapMania sharedInstance].glView.bounds;
	GLfloat	vertices[] = {	
		rect.origin.x,							rect.origin.y,							
		rect.origin.x + rect.size.width,		rect.origin.y,							
		rect.origin.x,							rect.origin.y + rect.size.height,		
		rect.origin.x + rect.size.width,		rect.origin.y + rect.size.height 
	};
	
	glColor4f(0.0f, 0.0f, 0.0f, m_fTransitionPosition);

	glDisable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glVertexPointer(2, GL_FLOAT, 0, vertices);	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glDisable(GL_BLEND);
	glEnable(GL_TEXTURE_2D);
	
	glColor4f(1, 1, 1, 1);
}

- (BOOL) updateTransitionIn:(float)fDelta { 
	[super updateTransitionIn:fDelta];
	
	float transDelta = fDelta / m_dTimeIn;
	m_fTransitionPosition += transDelta;
	
	if(m_fTransitionPosition >= 1.0f) {
		m_fTransitionPosition = 1.0f;

		return YES; // Ready
	}
	
	return NO; // Busy
}

- (BOOL) updateTransitionOut:(float)fDelta { 
	[super updateTransitionOut:fDelta];

	float transDelta = fDelta / m_dTimeOut;
	m_fTransitionPosition -= transDelta;
	
	if(m_fTransitionPosition <= 0.0f) {
		m_fTransitionPosition = 0.0f;
		
		return YES; // Ready
	}
	
	return NO; // Busy
}

@end
