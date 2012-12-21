//
//  $Id$
//  SlideEffect.m
//  TapMania
//
//  Created by Alex Kremer on 18.02.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "SlideEffect.h"
#import "PhysicsUtil.h"
#import "TapMania.h"

@interface SlideEffect (Calculations)
- (void)calculateAcceleration;
@end

@implementation SlideEffect

@synthesize m_dEffectTime, m_oDestination;

- (id)initWithRenderable:(id)renderable
{
    self = [super initWithRenderable:renderable];
    if (!self)
        return nil;

    m_nState = kSlideIdle;
    m_dEffectTime = kDefaultSlideEffectTime;
    m_pVelocity = [[Vector alloc] init];    // 0 vector

    return self;
}

- (void)dealloc
{
    [m_pCurrentPos release];
    [m_pVelocity release];
    [m_pAcceleration release];

    [super dealloc];
}

- (void)calculateAcceleration
{
    if (m_pCurrentPos)
        [m_pCurrentPos release];

    Vector *startPos = [[Vector alloc] initWithX:m_rShape.origin.x andY:m_rShape.origin.y];
    Vector *endPos = [[Vector alloc] initWithX:m_oDestination.x andY:m_oDestination.y];
    Vector *diffIdent = [Vector normalize:[Vector sub:endPos And:startPos] withTolerance:0.01f];

    float dist = [Vector dist:startPos And:endPos];
    float accel = (2.0f * dist) / (m_dEffectTime * m_dEffectTime);

    m_pAcceleration = [[Vector mulScalar:diffIdent And:accel] retain];
    m_pCurrentPos = [[Vector alloc] init];    // 0 vector

    [endPos release];
    [startPos release];

    TMLog(@"Calculated sliding acceleration is %f/%f", m_pAcceleration.x, m_pAcceleration.y);
}

/* TMLogicUpdater stuff */
- (void)update:(float)fDelta
{

    [super update:fDelta];
    m_rShape = [m_idDecoratedObject getShape];

    if (m_nState == kSlideTweening)
    {
        [m_pVelocity sum:[Vector mulScalar:m_pAcceleration And:fDelta]];
        [m_pCurrentPos sum:[Vector mulScalar:m_pVelocity And:fDelta]];

        m_rShape.origin.x += m_pCurrentPos.x;
        m_rShape.origin.y += m_pCurrentPos.y;

        if (m_dTweeningTime >= m_dEffectTime)
        {
            TMLog(@"Finished sliding");
            m_nState = kSlideFinished;
        }

        m_dTweeningTime += fDelta;
    } else if (m_nState == kSlideFinished)
    {
        m_rShape.origin.x += m_pCurrentPos.x;    // Keep the object on it's new location
        m_rShape.origin.y += m_pCurrentPos.y;
    }
}

- (BOOL)isTweening
{
    return m_nState == kSlideTweening;
}

- (BOOL)isFinished
{
    return m_nState == kSlideFinished;
}

- (void)startTweening
{
    TMLog(@"Slide: Start tweening");
    [self calculateAcceleration];
    m_nState = kSlideTweening;
    m_dTweeningTime = 0.0f;
}

@end
