//
//  $Id$
//  Judgement.h
//  TapMania
//
//  Created by Alex Kremer on 12.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "TMFramedTexture.h"
#import "TMLogicUpdater.h"
#import "TMRenderable.h"
#import "TMMessageSupport.h"
#import "Sprite.h"

typedef enum
{
    kJudgementW1 = 0,
    kJudgementW2,
    kJudgementW3,
    kJudgementW4,
    kJudgementW5,
    kJudgementMiss,
    kJudgementMineHit,
    kNumJudgementValues,
    kJudgementNone
} TMJudgement;

typedef enum
{
    kTimingFlagInvalid = -1,
    kTimingFlagEarly = 0,
    kTimingFlagLate
} TMTimingFlag;

@interface Judgement : Sprite <TMLogicUpdater, TMRenderable, TMMessageSupport>
{
    /* Metrics etc. */
    TMFramedTexture *m_texture;
}

- (void)reset;

@end
