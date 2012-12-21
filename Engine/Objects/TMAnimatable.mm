//
//  $Id$
//  TMAnimatable.m
//  TapMania
//
//  Created by Alex Kremer on 04.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMAnimatable.h"

@interface TMAnimatable (Private)
- (void)drawCurrentFrameInRect:(CGRect)rect;
@end

@implementation TMAnimatable

@synthesize m_nStartFrame, m_nEndFrame, m_fFrameTime, m_nCurrentFrame, m_bIsLooping, m_oFrameRect;

// Override TMFramedTexture constructor
- (id)initWithImage:(UIImage *)uiImage columns:(int)columns andRows:(int)rows
{
    self = [super initWithImage:uiImage columns:columns andRows:rows];
    if (!self)
        return nil;

    m_nStartFrame = 0;
    m_nEndFrame = 0;

    m_fFrameTime = 1.0f;
    m_nCurrentFrame = m_nStartFrame;
    m_bIsLooping = NO;

    // NOTE: Don't forget to set this before calling render
    m_oFrameRect = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);

    // Stop animation (show only currentFrame all the time)
    m_bIsAnimating = NO;

    return self;
}

- (void)startAnimation
{
    [self startAnimationFromFrame:0];
}

- (void)startAnimationFromFrame:(int)frameId
{
    m_fElapsedTime = 0.0f;
    m_nCurrentFrame = frameId;

    m_bIsAnimating = YES;
}

- (void)pauseAnimation
{
    m_bIsAnimating = NO;
}

- (void)continueAnimation
{
    m_bIsAnimating = YES;
}

- (void)stopAnimation
{
    m_bIsAnimating = NO;
}

/* TMRenderable method */
- (void)render:(float)fDelta
{
    [self drawFrame:m_nCurrentFrame inRect:m_oFrameRect];
}

/* TMLogicUpdater method */
- (void)update:(float)fDelta
{
    if (m_bIsAnimating)
    {
        m_fElapsedTime += fDelta;
        if (m_fElapsedTime > m_fFrameTime)
        {
            // Time to switch the frame
            // If not looping but hit first frame again - stop
            if (m_nCurrentFrame == m_nEndFrame && !m_bIsLooping)
            {
                m_bIsAnimating = NO;
            } else
            {
                m_nCurrentFrame = m_nCurrentFrame + 1 == m_nEndFrame ? m_nStartFrame : m_nCurrentFrame + 1;
            }

            m_fElapsedTime = 0.0f;
        }
    }
}

@end
