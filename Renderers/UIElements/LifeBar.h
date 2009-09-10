//
//  LifeBar.h
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMLogicUpdater.h"
#import "TMRenderable.h"

@class Texture2D;

@interface LifeBar : NSObject <TMRenderable, TMLogicUpdater> {
	float m_fCurrentValue;  // 0.0 -> 100.0 :: defaults to 50.0 on song start
	CGRect m_rShape;	// The rect where the lifebar is drawn
	
	/* Textures */
	Texture2D	*t_LifeBarBG, *t_LifeBarNormal, *t_LifeBarHot, *t_LifeBarFrame;
}

- (id) initWithRect:(CGRect)rect;

- (float) getCurrentValue;
- (void) updateBy:(float)value;

@end
