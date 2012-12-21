//
//  $Id$
//  SlideEffect.h
//  TapMania
//
//  Created by Alex Kremer on 18.02.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "BasicEffect.h"

typedef enum
{
    kSlideIdle = 0,
    kSlideTweening,
    kSlideFinished
} TMSlideEffectState;

#define        kDefaultSlideEffectTime        1.0

@class Vector;

@interface SlideEffect : BasicEffect
{
    TMSlideEffectState m_nState;

    double m_dEffectTime;    // The time in seconds for the effect to complete
    CGPoint m_oDestination;    // Destination point on screen

    Vector *m_pVelocity;    // Current velocity
    Vector *m_pCurrentPos;    // Current position on the way
    Vector *m_pAcceleration;    // Calculated acceleration

    double m_dTweeningTime;    // Time passed since animation start
}

@property(assign, setter=effectTime:, readwrite, getter=effectTime) double m_dEffectTime;
@property(assign, setter=destination:, readwrite, getter=destination) CGPoint m_oDestination;

- (BOOL)isFinished;

- (BOOL)isTweening;

- (void)startTweening;    // Trigger effect

@end
