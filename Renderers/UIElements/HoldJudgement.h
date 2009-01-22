//
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
#import "TMSteps.h"

#define HOLD_JUDGEMENT_MAX_SHOW_TIME 0.4	// Seconds 

typedef enum {
	kHoldJudgementNone = 0,
	kHoldJudgementOK,
	kHoldJudgementNG,
	kNumHoldJudgementValues
} TMHoldJudgement;

@interface HoldJudgement : TMFramedTexture <TMLogicUpdater, TMRenderable> {
	TMHoldJudgement _currentJudgement[kNumOfAvailableTracks];	// Currently displayed judgements for every track
	double _elapsedTime[kNumOfAvailableTracks];	// Time elapsed since last renew of the judgement in every track
	float _judgementXPositions[kNumOfAvailableTracks];
}

- (void) setCurrentHoldJudgement:(TMHoldJudgement)judgement forTrack:(TMAvailableTracks)track;

@end
