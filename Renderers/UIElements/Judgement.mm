//
//  $Id$
//  Judgement.m
//  TapMania
//
//  Created by Alex Kremer on 12.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "Judgement.h"
#import "ThemeManager.h"
#import "TMNote.h"
#import "TimingUtil.h"
#import "TMMessage.h"
#import "MessageManager.h"

@interface Judgement (Private)
- (void)drawJudgement:(int)frame;

- (void)setCurrentJudgement:(TMJudgement)judgement andTimingFlag:(TMTimingFlag)flag;
@end

@implementation Judgement

- (void)reset
{
}

- (id)initWithImage:(UIImage *)uiImage columns:(int)columns andRows:(int)rows
{
    self = [super init];
    if (!self)
        return nil;

    m_texture = [[TMFramedTexture alloc] initWithImage:uiImage columns:columns andRows:rows];
    self.texture = m_texture;

    // Cache metrics
    int mt_JudgementX = INT_METRIC(@"SongPlay Judgement X");
    int mt_JudgementY = INT_METRIC(@"SongPlay Judgement Y");

    [self setX:mt_JudgementX];
    [self setY:mt_JudgementY];
    [self setAlpha:0];

    SUBSCRIBE(kNoteScoreMessage);
    [self reset];

    return self;
}

- (void)dealloc
{
    UNSUBSCRIBE_ALL();
    [m_texture release];
    [super dealloc];
}

- (void)setCurrentJudgement:(TMJudgement)judgement andTimingFlag:(TMTimingFlag)flag
{
    frameIndex = judgement * 2 + flag;
    switch (judgement)
    {
        default:
            [self finishKeyFrames];
            [self setScaleX:1.3];
            [self setScaleY:1.6];
            [self setAlpha:1];
            [self pushKeyFrame:0.2];
            [self setScale:1];
            [self pushKeyFrame:1];
            [self pushKeyFrame:0];
            [self setAlpha:0];
            break;
        case kJudgementMiss:
            [self finishKeyFrames];
            [self addY:30];
            [self setAlpha:1];
            [self pushKeyFrame:1];
            [self addY:-60];
            [self pushKeyFrame:0];
            [self setAlpha:0];
            [self addY:30];
            break;
    }
}

/* TMRenderable method */
- (void)render:(float)fDelta
{
    [super render:fDelta];
}

/* TMLogicUpdater method */
- (void)update:(float)fDelta
{
}

/* TMMessageSupport stuff */
- (void)handleMessage:(TMMessage *)message
{
    switch (message.messageId)
    {
        case kNoteScoreMessage:

            TMNote *note = (TMNote *) message.payload;
            [self setCurrentJudgement:note.m_nScore andTimingFlag:note.m_nTimingFlag];

            break;
    }
}

@end
