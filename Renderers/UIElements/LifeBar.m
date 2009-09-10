//
//  LifeBar.m
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "LifeBar.h"
#import "Texture2D.h"
#import "ThemeManager.h"

@implementation LifeBar

- (id) initWithRect:(CGRect)rect {
	self = [super init];
	if(!self) 
		return nil;
	
	m_fCurrentValue = 0.5f;
	m_rShape = rect;
	
	// Preload all required graphics
	t_LifeBarBG = TEXTURE(@"SongPlay LifeBar Background");
	t_LifeBarNormal = TEXTURE(@"SongPlay LifeBar Normal");
	t_LifeBarHot = TEXTURE(@"SongPlay LifeBar Hot");
	t_LifeBarFrame = TEXTURE(@"SongPlay LifeBar Frame");
		
	return self;
}

- (float) getCurrentValue {
	return m_fCurrentValue;
}

- (void) updateBy:(float)value {
	m_fCurrentValue += value;
	if(m_fCurrentValue > 1.0) {
		m_fCurrentValue = 1.0f;
	} else if(m_fCurrentValue < 0.0) {
		m_fCurrentValue = 0.0f;
	}
}

/* TMRenderable method */
- (void) render:(float)fDelta {
	CGRect fillRect = CGRectMake(m_rShape.origin.x, m_rShape.origin.y, m_rShape.size.width*m_fCurrentValue, m_rShape.size.height);

	// Background first
	[t_LifeBarBG drawInRect:m_rShape];
	
	// TODO calculate stream from N springs and animate these
	
	if(m_fCurrentValue < 0.3) {
		// Show passing bar
		// TODO: get the image for passing (redir?)
		[t_LifeBarNormal drawInRect:fillRect];
	} else if(m_fCurrentValue < 1.0f) {
		// Show normal bar
		[t_LifeBarNormal drawInRect:fillRect];
	} else {
		// Show hot only if we are very good and having full lifebar
		[t_LifeBarHot drawInRect:fillRect];
	}

	glEnable(GL_BLEND);
	[t_LifeBarFrame drawInRect:m_rShape];
	glDisable(GL_BLEND);
}

/* TMLogicUpdater method */
- (void) update:(float)fDelta {

}

@end
