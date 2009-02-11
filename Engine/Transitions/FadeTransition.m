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
	
	return self;
}


// TMRenderable stuff
- (void)render:(NSNumber*)fDelta {	
	CGRect	bounds = [TapMania sharedInstance].glView.bounds;
	
	double alpha = m_dTimePassed;
	if(alpha > 1.0f) alpha = 1.0f;
	
	TMLog(@"RENDER transition with alpha %f", alpha);
	
//	if(m_nState == kTransitionStateIn) {
		glEnable(GL_BLEND);
		glColor4f(alpha, alpha, alpha, alpha);
		[t_Blank drawInRect: bounds];
		glColor4f(1, 1, 1, 1);
/*		
	} else if (m_nState == kTransitionStateOut) {
		alpha = 1.0f-alpha;
		
		glEnable(GL_BLEND);
		glColor4f(alpha, alpha, alpha, alpha);
		[t_Blank drawInRect: bounds];
		glColor4f(1, 1, 1, 1);		
	}
 */
}

@end
