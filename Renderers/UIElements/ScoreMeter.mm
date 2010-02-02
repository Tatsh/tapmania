//
//	$Id$
//  ScoreMeter.mm
//  TapMania
//
//  Created by Alex Kremer on 2/3/10.
//  Copyright 2010 Godexsoft. All rights reserved.
//

#import "ScoreMeter.h"
#import "TMNote.h"
#import "Judgement.h"

#import "ThemeManager.h"

#import "MessageManager.h"
#import "TMMessage.h"

#import "FontString.h"

@interface ScoreMeter (ScoringSystem)
+ (int) GetScore:(int)p :(int)B :(int)S :(int)n;
- (void) AddScore:(TMNote*)note;
@end


@implementation ScoreMeter

- (id) initWithMetrics:(NSString*)metricsKey forSteps:(TMSteps*)steps {
	self = [super init];
	if(!self) 
		return nil;
	
	// Cache metrics
	mt_ScoreFramePosition = POINT_METRIC(([NSString stringWithFormat:@"%@ Frame",metricsKey]));
	mt_ScoreTextLeftPosition = POINT_METRIC(([NSString stringWithFormat:@"%@ Score",metricsKey]));
	
	SUBSCRIBE(kNoteScoreMessage);
	m_nCurrentScore = 0;
	m_nTotalSteps = [steps getTotalNotes];
	m_nDifficulty = [steps getDifficultyLevel];
	m_nMaxPossiblePoints = 10000000*m_nDifficulty;
	m_nTapNotesHit = 0;
	
	TMLog(@"TotalSteps: %d\tDiff: %d\tMaxPossiblePoints: %d", m_nTotalSteps, m_nDifficulty, m_nMaxPossiblePoints);
	
	m_pScoreStr = [[FontString alloc] initWithFont:@"SongPlay ScoreNormalNumbers" andText:@"        0"];	
	[m_pScoreStr setAlignment:UITextAlignmentLeft];
	m_pScoreFrame = TEXTURE(([NSString stringWithFormat:@"%@ Frame",metricsKey]));
	
	return self;
}


/* TMMessageSupport stuff */
-(void) handleMessage:(TMMessage*)message {
	switch (message.messageId) {
		case kNoteScoreMessage:			
			
			TMNote* note = (TMNote*)message.payload;			
			[self AddScore:note];
			[m_pScoreStr updateText:[NSString stringWithFormat:@"%9d", m_nCurrentScore]];
			
			break;
	}
}

/* TMRenderable method */
- (void) render:(float)fDelta {
	glEnable(GL_BLEND);		
	[m_pScoreStr drawAtPoint:mt_ScoreTextLeftPosition];
	glDisable(GL_BLEND);	
}

/* TMLogicUpdater method */
- (void) update:(float)fDelta {
	
}

- (void) dealloc {
	UNSUBSCRIBE_ALL();
	[m_pScoreStr release];
	[super dealloc];
}


#pragma mark Stepmania scoring system algo below
+ (int) GetScore:(int)p :(int)B :(int)S :(int)n {
	return int(int64_t(p) * n * B / S);	
}

- (void) AddScore:(TMNote*)note {
	int p = 0;	// score multiplier 
	++m_nTapNotesHit;
	
	switch( note.m_nScore )
	{
		case kJudgementW1:	p = 10;		break;
		case kJudgementW2:	p = 9;		break;
		case kJudgementW3:	p = 5;		break;
		default:			p = 0;		break;
	}
	
	// To test a full marv score
	// p = 10;
	
	const int N = m_nTotalSteps;
	const int sum = (N * (N + 1)) / 2;
	const int B = m_nMaxPossiblePoints/10;
	
	int score = [ScoreMeter GetScore:p :B :sum :m_nTapNotesHit];
	TMLog(@"Score: %d", score);
	
	m_nCurrentScore += score;
}

@end
