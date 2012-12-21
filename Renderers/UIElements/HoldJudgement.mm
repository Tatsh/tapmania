//
//  $Id$
//  HoldJudgement.m
//  TapMania
//
//  Created by Alex Kremer on 22.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "HoldJudgement.h"
#import "ThemeManager.h"
#import "TMNote.h"
#import "TMMessage.h"
#import "MessageManager.h"

@interface HoldJudgement (Private)
- (void)drawHoldJudgement:(TMHoldJudgement)judgement forTrack:(TMAvailableTracks)track;

- (void)setCurrentHoldJudgement:(TMHoldJudgement)judgement forTrack:(TMAvailableTracks)track;
@end

@implementation HoldJudgement

- (void)drawHoldJudgement:(TMHoldJudgement)judgement forTrack:(TMAvailableTracks)track
{
    glEnable(GL_BLEND);
    [self drawFrame:judgement - 1 atPoint:mt_HoldJudgement[(int) track]];
    glDisable(GL_BLEND);
}

- (void)reset
{
    int i;
    for (i = 0; i < kNumOfAvailableTracks; ++i)
    {
        m_dElapsedTime[i] = 0.0f;
        m_nCurrentJudgement[i] = kHoldJudgementNone;
    }
}

- (id)initWithImage:(UIImage *)uiImage columns:(int)columns andRows:(int)rows
{
    self = [super initWithImage:uiImage columns:columns andRows:rows];
    if (!self)
        return nil;

    // Cache metrics
    for (int i = 0; i < kNumOfAvailableTracks; ++i)
    {
        mt_HoldJudgement[i] = POINT_METRIC(([NSString stringWithFormat:@"SongPlay HoldJudgement %d", i]));
    }

    mt_HoldJudgementMaxShowTime = FLOAT_METRIC(@"SongPlay HoldJudgement MaxShowTime");

    // Subscribe for messages
    SUBSCRIBE(kHoldHeldMessage);
    SUBSCRIBE(kHoldLostMessage);

    [self reset];

    return self;
}

- (void)dealloc
{
    UNSUBSCRIBE_ALL();
    [super dealloc];
}

- (void)setCurrentHoldJudgement:(TMHoldJudgement)judgement forTrack:(TMAvailableTracks)track
{
    m_dElapsedTime[track] = 0.0f;
    m_nCurrentJudgement[track] = judgement;
}

/* TMRenderable method */
- (void)render:(float)fDelta
{

    int i;
    for (i = 0; i < kNumOfAvailableTracks; ++i)
    {
        if (m_nCurrentJudgement[i] != kHoldJudgementNone)
        {
            [self drawHoldJudgement:m_nCurrentJudgement[i] forTrack:(TMAvailableTracks) i];
        }
    }
}

/* TMLogicUpdater method */
- (void)update:(float)fDelta
{

    int i;
    for (i = 0; i < kNumOfAvailableTracks; ++i)
    {

        // If we show some judgement we must fade it out after some period of time
        if (m_nCurrentJudgement[i] != kHoldJudgementNone)
        {
            m_dElapsedTime[i] += fDelta;

            if (m_dElapsedTime[i] >= mt_HoldJudgementMaxShowTime)
            {
                m_dElapsedTime[i] = 0.0f;
                m_nCurrentJudgement[i] = kHoldJudgementNone;
            }
        }
    }
}

/* TMMessageSupport stuff */
- (void)handleMessage:(TMMessage *)message
{
    TMNote *note = nil;

    switch (message.messageId)
    {
        case kHoldLostMessage:

            note = (TMNote *) message.payload;
            [self setCurrentHoldJudgement:kHoldJudgementNG forTrack:note.m_nTrack];

            break;

        case kHoldHeldMessage:

            note = (TMNote *) message.payload;
            [self setCurrentHoldJudgement:kHoldJudgementOK forTrack:note.m_nTrack];

            break;
    }
}

@end
