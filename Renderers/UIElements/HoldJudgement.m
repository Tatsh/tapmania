//
//  HoldJudgement.m
//  TapMania
//
//  Created by Alex Kremer on 22.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "HoldJudgement.h"

@interface HoldJudgement (Private) 
- (void) drawHoldJudgement:(TMHoldJudgement)judgement forTrack:(TMAvailableTracks)track;
@end

@implementation HoldJudgement

- (void) drawHoldJudgement:(TMHoldJudgement)judgement forTrack:(TMAvailableTracks)track {
	[self drawFrame:judgement-1 atPoint:CGPointMake( _judgementXPositions[track], 325 )];
}

- (id) initWithImage:(UIImage *)uiImage columns:(int)columns andRows:(int)rows {
	self = [super initWithImage:uiImage columns:columns andRows:rows];
	if(!self) 
		return nil;
	
	// Precalculate stuff
	float currentOffset = 0.0f;
	int i;
	
	// FIXME: this should go to theme->metrics..
	for(i=0; i<kNumOfAvailableTracks; ++i) {
		_judgementXPositions[i] = 45 + currentOffset;
		
		currentOffset += 70; // 64 as width of the receptor + 6 as spacing
		
		_elapsedTime[i] = 0.0f;
		_currentJudgement[i] = kHoldJudgementNone;
	}	
	
	return self;
}

- (void) setCurrentHoldJudgement:(TMHoldJudgement)judgement forTrack:(TMAvailableTracks)track {
	_elapsedTime[track] = 0.0f;
	_currentJudgement[track] = judgement;
}

/* TMRenderable method */
- (void) render:(NSNumber*)fDelta {
	
	int i;
	for(i=0; i<kNumOfAvailableTracks; ++i) {			
		if(_currentJudgement[i] != kHoldJudgementNone) {
			[self drawHoldJudgement:_currentJudgement[i] forTrack:i];
		}
	}
}

/* TMLogicUpdater method */
- (void) update:(NSNumber*)fDelta {

	int i;
	for(i=0; i<kNumOfAvailableTracks; ++i) {			

		// If we show some judgement we must fade it out after some period of time
		if(_currentJudgement[i] != kHoldJudgementNone) {
			_elapsedTime[i] += [fDelta floatValue];
		
			if(_elapsedTime[i] >= HOLD_JUDGEMENT_MAX_SHOW_TIME) {
				_elapsedTime[i] = 0.0f;
				_currentJudgement[i] = kHoldJudgementNone;
			}
		}
	}
}

@end
