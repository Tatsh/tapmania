//
//  Judgement.m
//  TapMania
//
//  Created by Alex Kremer on 12.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "Judgement.h"
#import "ThemeManager.h"

@interface Judgement (Private) 
- (void) drawJudgement:(TMJudgement) judgement;
@end

static int mt_JudgementX, mt_JudgementY;
static float mt_JudgementMaxShowTime;

@implementation Judgement

- (void) drawJudgement:(TMJudgement) judgement {
	glEnable(GL_BLEND);
	[self drawFrame:judgement-1 atPoint:CGPointMake(mt_JudgementX, mt_JudgementY)];
	glDisable(GL_BLEND);
}

- (id) initWithImage:(UIImage *)uiImage columns:(int)columns andRows:(int)rows {
	self = [super initWithImage:uiImage columns:columns andRows:rows];
	if(!self) 
		return nil;

	// Cache metrics
	mt_JudgementX = [[ThemeManager sharedInstance] intMetric:@"SongPlay Judgement X"];
	mt_JudgementY = [[ThemeManager sharedInstance] intMetric:@"SongPlay Judgement Y"];
	mt_JudgementMaxShowTime = [[ThemeManager sharedInstance] floatMetric:@"SongPlay Judgement MaxShowTime"];
	
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
	
		if(m_dElapsedTime >= mt_JudgementMaxShowTime) {
			m_dElapsedTime = 0.0f;
			m_nCurrentJudgement = kJudgementNone;
		}
	}
}

@end
