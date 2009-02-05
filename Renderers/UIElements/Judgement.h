//
//  Judgement.h
//  TapMania
//
//  Created by Alex Kremer on 12.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMFramedTexture.h"
#import "TMLogicUpdater.h"
#import "TMRenderable.h"

typedef enum {
	kJudgementNone = 0,
	kJudgementW1,
	kJudgementW2,
	kJudgementW3,
	kJudgementW4,
	kJudgementW5,
	kJudgementMiss,
	kNumJudgementValues
} TMJudgement;

@interface Judgement : TMFramedTexture <TMLogicUpdater, TMRenderable> {
	TMJudgement m_nCurrentJudgement;	// Currently displayed judgement
	double m_dElapsedTime;	// Time elapsed since last renew of the judgement
}

- (void) setCurrentJudgement:(TMJudgement) judgement;

@end
