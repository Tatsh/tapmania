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

#define JUDGEMENT_MAX_SHOW_TIME 1.0	// Seconds 

typedef enum {
	kJudgementNone = 0,
	kJudgementW1,
	kJudgementW2,
	kJudgementW3,
	kJudgementW4,
	kJudgementW5,
	kNumJudgementValues
} JudgementValues;

@interface Judgement : TMFramedTexture <TMLogicUpdater, TMRenderable> {
	JudgementValues _currentJudgement;	// Currently displayed judgement
	double _elapsedTime;	// Time elapsed since last renew of the judgement
}

// Drawing routine. This routine will replace currently shown judgement sprite
- (void) drawJudgement:(JudgementValues) judgement;

@end
