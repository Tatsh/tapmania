//
//  TMAnimatable.h
//  TapMania
//
//  Created by Alex Kremer on 04.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMFramedTexture.h"
#import "TMRenderable.h"
#import "TMLogicUpdater.h"

@interface TMAnimatable : TMFramedTexture <TMRenderable, TMLogicUpdater> {
	// Specify the frames used for the animation
	int startFrame;		// Defaults to 0
	int endFrame;		// Defaults to 0
	
	float frameTime;	// Every frame in the animation will be rendered for this amount of time. defaults to 1.0 second
	float elapsedTime;	// The time passed since we switched to currentFrame
	int currentFrame;	// Current frame index from 0 to framesCount. defaults to 0
	
	CGRect frameRect;	// The place to render the animation. must be set before using render facilities
	BOOL animating;		// A flag to start/stop animation
	BOOL looping;		// Specifies whether the animation should loop. defaults to NO
}

// These properties are used to tune the behavior of the animation
@property(assign) int startFrame;
@property(assign) int endFrame;
@property(assign) float frameTime;
@property(assign) int currentFrame;
@property(assign) BOOL looping;
@property(assign,nonatomic) CGRect frameRect;

- (void) startAnimation;
- (void) startAnimationFromFrame:(int)frameId;
- (void) pauseAnimation;
- (void) continueAnimation;
- (void) stopAnimation;

@end
