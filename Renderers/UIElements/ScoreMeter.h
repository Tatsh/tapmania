//
//	$Id$
//  ScoreMeter.h
//  TapMania
//
//  Created by Alex Kremer on 2/3/10.
//  Copyright 2010 Godexsoft. All rights reserved.
//

#import "TMLogicUpdater.h"
#import "TMRenderable.h"
#import "TMMessageSupport.h"

@class TMSteps;
@class FontString, Texture2D;

@interface ScoreMeter : NSObject <TMLogicUpdater, TMRenderable, TMMessageSupport>
{
    int m_nCurrentScore;
    int m_nNewScore;

    int m_nTotalSteps;
    int m_nTapNotesHit;
    int m_nDifficulty;
    int m_nMaxPossiblePoints;
    int m_nRoundTo;
    int m_nScoreRemainder;

    FontString *m_pScoreStr;
    Texture2D *m_pScoreFrame;

    // Metrics and such
    CGPoint mt_ScoreFramePosition;
    CGPoint mt_ScoreTextLeftPosition;
}

- (id)initWithMetrics:(NSString *)metricsKey forSteps:(TMSteps *)steps;

- (long)getScore;

@end
