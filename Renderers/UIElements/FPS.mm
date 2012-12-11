//
//  $Id$
//  FPS.m
//  TapMania
//
//  Created by Alex Kremer on 13.02.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "FPS.h"
#import "Texture2D.h"
#import "DisplayUtil.h"

@implementation FPS

- (id) init {
	self = [super initWithShape:CGRectMake(0, 0, [DisplayUtil getDeviceDisplaySize].width, 20)];
	if(!self) return nil;
	
	m_lFpsCounter = 0;
	m_dTimeCounter = 0.0;
	
	m_pCurrentTexture = [[Texture2D alloc] initWithString:@"FPS: 0" dimensions:m_rShape.size alignment:UITextAlignmentRight fontName:@"Arial" fontSize:16];
	
	return self;
}

/* TMRenderable method */
/* Updates are also done here because we actually want to count drawing only */
- (void) render:(float)fDelta {
	m_dTimeCounter += fDelta;
	
	if(m_dTimeCounter > 1.0f) {
		m_lFpsCounter /= m_dTimeCounter;		

		if(m_pCurrentTexture) {
			[m_pCurrentTexture release];
		}
		
		m_pCurrentTexture = [[Texture2D alloc] initWithString:[NSString stringWithFormat:@"FPS: %ld", m_lFpsCounter]
												   dimensions:m_rShape.size alignment:UITextAlignmentRight fontName:@"Arial" fontSize:16];
		
		m_dTimeCounter = 0.0;
		m_lFpsCounter = 0;
	}
	
	++m_lFpsCounter;
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	[m_pCurrentTexture drawInRect:m_rShape];
	
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_BLEND);
}

@end
