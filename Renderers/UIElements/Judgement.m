//
//  Judgement.m
//  TapMania
//
//  Created by Alex Kremer on 12.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "Judgement.h"


@implementation Judgement

- (void) drawJudgement:(JudgementValues) judgement {
	[self drawFrame:judgement-1 atPoint:CGPointMake( 160, 240 )];
}

/* TMRenderable method */
- (void) render:(NSNumber*)fDelta {
	[self drawFrame:currentFrame inRect:frameRect];
}

/* TMLogicUpdater method */
- (void) update:(NSNumber*)fDelta {
	if(animating) {
		elapsedTime += [fDelta floatValue];
		if(elapsedTime > frameTime) {
			// Time to switch the frame
			// If not looping but hit first frame again - stop
			if(currentFrame == endFrame && !looping) {
				animating = NO;
			} else {
				currentFrame = currentFrame+1==endFrame ? startFrame : currentFrame+1;
			}
			
			elapsedTime = 0.0f;
		}
	}
}

@end
