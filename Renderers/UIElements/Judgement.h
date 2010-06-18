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

typedef enum {
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

typedef enum {
	kTimingFlagInvalid = -1,
	kTimingFlagEarly = 0,
	kTimingFlagLate	
} TMTimingFlag;

@interface Judgement : NSObject <TMLogicUpdater, TMRenderable, TMMessageSupport> {
	TMJudgement m_nCurrentJudgement;	// Currently displayed judgement
	TMTimingFlag m_nCurrentFlag;
	double m_dElapsedTime;	// Time elapsed since last renew of the judgement
	
	/* Metrics etc. */
	TMFramedTexture* m_texture;
	int mt_JudgementX, mt_JudgementY;
	float mt_JudgementMaxShowTime;
}

- (void) reset;

@end
