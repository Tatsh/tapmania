//
//  $Id$
//  LifeBar.m
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "LifeBar.h"
#import "Texture2D.h"
#import "ThemeManager.h"
#import "TimingUtil.h"
#import "TMNote.h"

#import "MessageManager.h"
#import "TMMessage.h"

@interface LifeBar (Private)
- (void)updateBy:(float)value;
@end

@implementation LifeBar

- (id)initWithRect:(CGRect)rect
{
    self = [super init];
    if (!self)
        return nil;

    // Register messages broadcasted by the lifebar handler
    REG_MESSAGE(kLifeBarDrainedMessage, @"LifeBarDrained");
    REG_MESSAGE(kLifeBarWarningMessage, @"LifeBarWarning");
    REG_MESSAGE(kLifeBarBackNormalMessage, @"LifeBarRecovered");

    m_fCurrentValue = 0.5f;
    m_rShape = rect;
    m_bIsActive = YES;

    // Preload all required graphics
    t_LifeBarBG = TEXTURE(@"SongPlay LifeBar Background");
    t_LifeBarNormal = TEXTURE(@"SongPlay LifeBar Normal");
    t_LifeBarPassing = TEXTURE(@"SongPlay LifeBar Passing");
    t_LifeBarHot = TEXTURE(@"SongPlay LifeBar Hot");
    t_LifeBarFrame = TEXTURE(@"SongPlay LifeBar Frame");

    // Subscribe to messages
    SUBSCRIBE(kNoteScoreMessage);
    SUBSCRIBE(kHoldHeldMessage);
    SUBSCRIBE(kHoldLostMessage);

    m_bWarningBroadcasted = NO;

    return self;
}

- (void)dealloc
{
    UNSUBSCRIBE_ALL();
    [super dealloc];
}

- (float)getCurrentValue
{
    return m_fCurrentValue;
}

- (void)updateBy:(float)value
{
    m_fCurrentValue += value;
    if (m_fCurrentValue > 1.0)
    {
        m_fCurrentValue = 1.0f;
    } else if (m_fCurrentValue < 0.0)
    {
        m_fCurrentValue = 0.0f;
    }
}

/* TMRenderable method */
- (void)render:(float)fDelta
{
    CGRect fillRect = CGRectMake(m_rShape.origin.x, m_rShape.origin.y, m_rShape.size.width * m_fCurrentValue, m_rShape.size.height);

    // Background first
    [t_LifeBarBG drawInRect:m_rShape];

    // TODO calculate stream from N springs and animate these

    if (m_fCurrentValue < 0.3)
    {
        // Show passing bar
        [t_LifeBarPassing drawInRect:fillRect];
    } else if (m_fCurrentValue < 1.0f)
    {
        // Show normal bar
        [t_LifeBarNormal drawInRect:fillRect];
    } else
    {
        // Show hot only if we are very good and having full lifebar
        [t_LifeBarHot drawInRect:fillRect];
    }

    glEnable(GL_BLEND);
    [t_LifeBarFrame drawInRect:m_rShape];
    glDisable(GL_BLEND);
}

/* TMLogicUpdater method */
- (void)update:(float)fDelta
{
    // Check current value
    if (!m_bWarningBroadcasted && m_fCurrentValue <= 0.3f)
    {
        BROADCAST_MESSAGE(kLifeBarWarningMessage, nil);
        m_bWarningBroadcasted = YES;
    }
    else if (m_bWarningBroadcasted && m_fCurrentValue > 0.3f)
    {
        BROADCAST_MESSAGE(kLifeBarBackNormalMessage, nil);
        m_bWarningBroadcasted = NO;
    }

    if (m_fCurrentValue < kMinLifeToKeepAlive && m_bIsActive)
    {
        BROADCAST_MESSAGE(kLifeBarDrainedMessage, nil);

        m_fCurrentValue = 0.0f;    // Drop to zero
        m_bIsActive = NO;
    }
}

/* TMMessageSupport stuff */
- (void)handleMessage:(TMMessage *)message
{
    if (!m_bIsActive)
        return;

    switch (message.messageId)
    {
        case kNoteScoreMessage:
        {

            TMNote *note = (TMNote *) message.payload;
            [self updateBy:[TimingUtil getLifebarChangeByNoteScore:note.m_nScore]];

            break;
        }
        case kHoldHeldMessage:
        {

            [self updateBy:0.008];    // OK judgement

            break;
        }
        case kHoldLostMessage:
        {

            [self updateBy:-0.080];    // NG judgement

            break;
        }
    }
}

@end
