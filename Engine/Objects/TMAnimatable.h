//
//  TMAnimatable.h
//  TapMania
//
//  Created by Alex Kremer on 04.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMRenderable.h"
#import "TMLogicUpdater.h"

@interface TMAnimatable : NSObject <TMRenderable, TMLogicUpdater> {
	int textureId;		// Texture for the animation
	int textureRow;		// Animation row in the texture. 0 is the first animation row
	
	float frameTime;	// Every frame in the animation will be rendered for this amount of time. defaults to 1.0 second
	float elapsedTime;	// The time passed since we switched to currentFrame
	int currentFrame;	// Current frame index from 0 to framesCount. defaults to 0
	int totalFrames;	// Total count of loaded frames. defaults to 1
	
	CGRect frameRect;	// The place to render the animation as well as the size of the frame
	BOOL animating;		// A flag to start/stop animation
	BOOL looping;		// Specifies whether the animation should loop. defaults to NO
}

// These properties are used to tune the behavior of the animation
@property(assign) int totalFrames;
@property(assign) float frameTime;
@property(assign) int currentFrame;
@property(assign) BOOL looping;

// Constructor
- (id) initWithTexture:(int)lTextureId row:(int)lTextureRow andFrameRect:(CGRect)lRect;

- (void) startAnimation;
- (void) startAnimationFromFrame:(int)frameId;
- (void) pauseAnimation;
- (void) continueAnimation;
- (void) stopAnimation;

@end
