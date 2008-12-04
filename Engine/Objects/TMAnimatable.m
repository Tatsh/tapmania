//
//  TMAnimatable.m
//  TapMania
//
//  Created by Alex Kremer on 04.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMAnimatable.h"
#import "TexturesHolder.h"

@implementation TMAnimatable

@synthesize totalFrames, frameTime, currentFrame, looping;

- (id) initWithTexture:(int)lTextureId row:(int)lTextureRow andFrameRect:(CGRect)lRect {
	self = [super init];
	if(!self)
		return nil;
	
	totalFrames = 1;
	frameTime = 1.0f;
	currentFrame = 0;
	looping = NO;
	
	textureId = lTextureId;
	textureRow = lTextureRow;
	frameRect = lRect;
	
	// Stop animation (show only currentFrame all the time)
	animating = NO;
	
	return self;
}

- (void) startAnimation {
	[self startAnimationFromFrame:0];
}

- (void) startAnimationFromFrame:(int)frameId {
	elapsedTime = 0.0f;
	currentFrame = frameId;
	
	animating = YES;
}

- (void) pauseAnimation {
	animating = NO;
}

- (void) continueAnimation {
	animating = YES;
}

- (void) stopAnimation {
	animating = NO;
}


/* TMRenderable method */
- (void) render:(NSNumber*)fDelta {
	[[[TexturesHolder sharedInstance] getTexture:textureId] drawFrame:currentFrame fromRow:textureRow inRect:frameRect];
}

/* TMLogicUpdater method */
- (void) update:(NSNumber*)fDelta {
	if(animating) {
		elapsedTime += [fDelta floatValue];
		if(elapsedTime > frameTime) {
			// Time to switch the frame
			// If not looping but hit first frame again - stop
			if(currentFrame+1 == totalFrames && !looping) {
				animating = NO;
			} else {
				currentFrame = currentFrame+1==totalFrames ? 0 : currentFrame+1;
			}
			
			elapsedTime = 0.0f;
		}
	}
}

@end
