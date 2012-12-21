//
//  $Id$
//  HoldJudgement.h
//  TapMania
//
//  Created by Alex Kremer on 22.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMFramedTexture.h"
#import "TMLogicUpdater.h"
#import "TMRenderable.h"
#import "TMMessageSupport.h"
#import "TMSteps.h"	// For kNumOfAvailableTracks

#define HOLD_JUDGEMENT_MAX_SHOW_TIME 0.4    // Seconds

typedef enum
{
    kHoldJudgementNone = 0,
    kHoldJudgementOK,
    kHoldJudgementNG,
    kNumHoldJudgementValues
} TMHoldJudgement;

@interface HoldJudgement : TMFramedTexture <TMLogicUpdater, TMRenderable, TMMessageSupport>
{
    TMHoldJudgement m_nCurrentJudgement[kNumOfAvailableTracks];    // Currently displayed judgements for every track
    double m_dElapsedTime[kNumOfAvailableTracks];    // Time elapsed since last renew of the judgement in every track

    /* Metrics and such */
    CGPoint mt_HoldJudgement[kNumOfAvailableTracks];
    float mt_HoldJudgementMaxShowTime;
}

- (void)reset;

@end
