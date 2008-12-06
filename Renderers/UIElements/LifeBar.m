//
//  LifeBar.m
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "LifeBar.h"

#import "TexturesHolder.h"

@implementation LifeBar

- (id) initWithRect:(CGRect)lRect {
	self = [super init];
	if(!self) 
		return nil;
	
	_currentValue = 0.5f;
	rect = lRect;
	
	return self;
}

- (float) getCurrentValue {
	return _currentValue;
}

- (void) updateBy:(float)value {
	_currentValue += value;
}

/* TMRenderable method */
- (void) render:(NSNumber*)fDelta {
	CGRect fillRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width*_currentValue, rect.size.height);
	
	// TODO calculate stream from N springs and animate these
	
	if(_currentValue < 1.0f) {
		// Show normal bar
		[[[TexturesHolder sharedInstance] getTexture:kTexture_LifeBarNormal] drawInRect:fillRect];
	} else {
		// Show hot only if we are very good and having full lifebar
		[[[TexturesHolder sharedInstance] getTexture:kTexture_LifeBarHot] drawInRect:fillRect];
	}

	[[[TexturesHolder sharedInstance] getTexture:kTexture_LifeBarFrame] drawInRect:rect];
}

/* TMLogicUpdater method */
- (void) update:(NSNumber*)fDelta {

}

@end
