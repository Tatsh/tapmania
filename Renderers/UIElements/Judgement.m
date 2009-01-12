//
//  Judgement.m
//  TapMania
//
//  Created by Alex Kremer on 12.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "Judgement.h"

@interface Judgement (Private) 
- (void) drawJudgement:(JudgementValues) judgement;
@end

@implementation Judgement

- (void) drawJudgement:(JudgementValues) judgement {
	[self drawFrame:judgement-1 atPoint:CGPointMake( 160, 240 )];
}

- (id) initWithImage:(UIImage *)uiImage columns:(int)columns andRows:(int)rows {
	self = [super initWithImage:uiImage columns:columns andRows:rows];
	if(!self) 
		return nil;

	_elapsedTime = 0.0f;
	_currentJudgement = kJudgementNone;

	return self;
}

- (void) setCurrentJudgement:(JudgementValues) judgement {
	_elapsedTime = 0.0f;
	_currentJudgement = judgement;
}

/* TMRenderable method */
- (void) render:(NSNumber*)fDelta {
	
	// Just draw the current judgement if it's not set to none
	if(_currentJudgement != kJudgementNone) {
		[self drawJudgement:_currentJudgement];
	}
}

/* TMLogicUpdater method */
- (void) update:(NSNumber*)fDelta {
	
	// If we show some judgement we must fade it out after some period of time
	if(_currentJudgement != kJudgementNone) {
		_elapsedTime += [fDelta floatValue];
	
		if(_elapsedTime >= JUDGEMENT_MAX_SHOW_TIME) {
			_elapsedTime = 0.0f;
			_currentJudgement = kJudgementNone;
		}
	}
}

@end
