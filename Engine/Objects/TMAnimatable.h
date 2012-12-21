//
//  $Id$
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

@interface TMAnimatable : TMFramedTexture <TMRenderable, TMLogicUpdater>
{
    // Specify the frames used for the animation
    int m_nStartFrame;        // Defaults to 0
    int m_nEndFrame;        // Defaults to 0

    float m_fFrameTime;    // Every frame in the animation will be rendered for this amount of time. defaults to 1.0 second
    float m_fElapsedTime;    // The time passed since we switched to currentFrame
    int m_nCurrentFrame;    // Current frame index from 0 to framesCount. defaults to 0

    CGRect m_oFrameRect;    // The place to render the animation. must be set before using render facilities
    BOOL m_bIsAnimating;        // A flag to start/stop animation
    BOOL m_bIsLooping;        // Specifies whether the animation should loop. defaults to NO
}

// These properties are used to tune the behavior of the animation
@property(assign) int m_nStartFrame;
@property(assign) int m_nEndFrame;
@property(assign) float m_fFrameTime;
@property(assign) int m_nCurrentFrame;
@property(assign) BOOL m_bIsLooping;
@property(assign, nonatomic) CGRect m_oFrameRect;

- (void)startAnimation;

- (void)startAnimationFromFrame:(int)frameId;

- (void)pauseAnimation;

- (void)continueAnimation;

- (void)stopAnimation;

@end
