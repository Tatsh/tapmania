//
//  TMAnimatable.m
//  TapMania
//
//  Created by Alex Kremer on 04.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMAnimatable.h"
#import "TexturesHolder.h"

@interface TMAnimatable (Private)
- (void) drawCurrentFrameInRect:(CGRect)rect;
@end

@implementation TMAnimatable

@synthesize startFrame, endFrame, frameTime, currentFrame, looping, frameRect;

// Override TMFramedTexture constructor
- (id) initWithImage:(UIImage *)uiImage columns:(int)columns andRows:(int)rows {
	self = [super initWithImage:uiImage columns:columns andRows:rows];
	if(!self)
		return nil;

	startFrame = 0;
	endFrame = 0;
	
	frameTime = 1.0f;
	currentFrame = startFrame;
	looping = NO;
	
	// NOTE: Don't forget to set this before calling render
	frameRect = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
	
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
	[self drawFrame:currentFrame inRect:frameRect];
}

/* TMLogicUpdater method */
- (void) update:(NSNumber*)fDelta {
	if(animating) {
		elapsedTime += [fDelta floatValue];
		if(elapsedTime > frameTime) {
			// Time to switch the frame
			// If not looping but hit first frame again - stop
			if(currentFrame == endFrame && !looping) {
				animating = NO;
			} else {
				currentFrame = currentFrame+1==endFrame ? startFrame : currentFrame+1;
			}
			
			elapsedTime = 0.0f;
		}
	}
}

@end
