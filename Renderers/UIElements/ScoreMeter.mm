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
#import "GameState.h"

extern TMGameState *g_pGameState;

@interface ScoreMeter (ScoringSystem)
+ (int)GetScore:(int)p :(int)B :(int)S :(int)n;

- (void)AddScore:(TMJudgement)judge;

- (void)updateScore:(TMJudgement)judge;
@end


@implementation ScoreMeter

- (id)initWithMetrics:(NSString *)metricsKey forSteps:(TMSteps *)steps
{
    self = [super init];
    if (!self)
        return nil;

    // Cache metrics
    mt_ScoreFramePosition = POINT_METRIC(([NSString stringWithFormat:@"%@ Frame", metricsKey]));
    mt_ScoreTextLeftPosition = POINT_METRIC(([NSString stringWithFormat:@"%@ Score", metricsKey]));

    SUBSCRIBE(kNoteScoreMessage);
    SUBSCRIBE(kHoldHeldMessage);

    m_nCurrentScore = 0;
    m_nTotalSteps = [steps getTotalTapAndHoldNotes] + [steps getTotalHolds];
    m_nDifficulty = [steps getDifficultyLevel];
    m_nMaxPossiblePoints = 10000000; // *m_nDifficulty;
    m_nTapNotesHit = 0;

    m_nScoreRemainder = 0;
    m_nRoundTo = 1; // Max2 Scoring

    TMLog(@"TotalSteps: %d\tDiff: %d\tMaxPossiblePoints: %d", m_nTotalSteps, m_nDifficulty, m_nMaxPossiblePoints);

    m_pScoreStr = [[FontString alloc] initWithFont:@"SongPlay ScoreNormalNumbers" andText:@"       0"];
    [m_pScoreStr setAlignment:UITextAlignmentLeft];
    m_pScoreFrame = TEXTURE(([NSString stringWithFormat:@"%@Frame", metricsKey]));

    return self;
}


/* TMMessageSupport stuff */
- (void)handleMessage:(TMMessage *)message
{
    switch (message.messageId)
    {
        case kHoldHeldMessage:    // OK counts as marvelous in score
            [self updateScore:kJudgementW1];

            break;

        case kNoteScoreMessage:

            TMNote *note = (TMNote *) message.payload;
            [self updateScore:note.m_nScore];

            break;
    }
}

- (void)updateScore:(TMJudgement)judge
{
    [self AddScore:judge];
    [m_pScoreStr updateText:[NSString stringWithFormat:@"%8ld", m_nCurrentScore]];
}

- (long)getScore
{
    return m_nCurrentScore;
}

/* TMRenderable method */
- (void)render:(float)fDelta
{
    glEnable(GL_BLEND);
//	[m_pScoreFrame drawAtPoint:mt_ScoreFramePosition];
    [m_pScoreStr drawAtPoint:mt_ScoreTextLeftPosition];
    glDisable(GL_BLEND);
}

/* TMLogicUpdater method */
- (void)update:(float)fDelta
{

}

- (void)dealloc
{
    UNSUBSCRIBE_ALL();
    [m_pScoreStr release];
    [super dealloc];
}


#pragma mark Stepmania scoring system algo below
+ (int)GetScore:(int)p :(int)B :(int)S :(int)n
{
    return int(int64_t(p) * n * B / S);
//	return int(p * n * (float(B) / S));
//	return p * (B / S) * n;
}

- (void)AddScore:(TMJudgement)judge
{
    int p = 0;    // score multiplier
    ++m_nTapNotesHit;

    switch (judge)
    {
        case kJudgementW1:
            p = 10;
            break;
        case kJudgementW2:
            p = 9;
            break;
        case kJudgementW3:
            p = 5;
            break;
        default:
            p = 0;
            break;
    }

    if (g_pGameState->m_bFailed && p > 0)
    {
        p = 1; // No multiplier if failed already
    }

    // To test a full marv score
    // p = 10;

    const int N = m_nTotalSteps;
    const int sum = (N * (N + 1)) / 2;
    const int B = m_nMaxPossiblePoints / 10;

    // Fixme: this is a dirty hack with the abs here
    int score = [ScoreMeter GetScore:p :B :sum :m_nTapNotesHit];
    m_nCurrentScore += score;

    // Reround
    m_nCurrentScore += m_nScoreRemainder;
    m_nScoreRemainder = (m_nCurrentScore % m_nRoundTo);
    m_nCurrentScore = m_nCurrentScore - m_nScoreRemainder;
}

@end
