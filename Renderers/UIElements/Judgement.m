//
//  Judgement.m
//  TapMania
//
//  Created by Alex Kremer on 12.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "Judgement.h"

@interface Judgement (Private) 
- (void) drawJudgement:(TMJudgement) judgement;
@end

@implementation Judgement

- (void) drawJudgement:(TMJudgement) judgement {
	[self drawFrame:judgement-1 atPoint:CGPointMake( 160, 240 )];
}

- (id) initWithImage:(UIImage *)uiImage columns:(int)columns andRows:(int)rows {
	self = [super initWithImage:uiImage columns:columns andRows:rows];
	if(!self) 
		return nil;

	m_dElapsedTime = 0.0f;
	m_nCurrentJudgement = kJudgementNone;

	return self;
}

- (void) setCurrentJudgement:(TMJudgement) judgement {
	m_dElapsedTime = 0.0f;
	m_nCurrentJudgement = judgement;
}

/* TMRenderable method */
- (void) render:(NSNumber*)fDelta {
	
	// Just draw the current judgement if it's not set to none
	if(m_nCurrentJudgement != kJudgementNone) {
		[self drawJudgement:m_nCurrentJudgement];
	}
}

/* TMLogicUpdater method */
- (void) update:(NSNumber*)fDelta {
	
	// If we show some judgement we must fade it out after some period of time
	if(m_nCurrentJudgement != kJudgementNone) {
		m_dElapsedTime += [fDelta floatValue];
	
		if(m_dElapsedTime >= JUDGEMENT_MAX_SHOW_TIME) {
			m_dElapsedTime = 0.0f;
			m_nCurrentJudgement = kJudgementNone;
		}
	}
}

@end
