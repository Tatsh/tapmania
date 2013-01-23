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
#import "DisplayUtil.h"
#import "GameState.h"
#import "PhysicsUtil.h"

extern TMGameState *g_pGameState;

@interface LifeBar (Private)
- (void)updateBy:(float)value;
@end

@implementation LifeBar

- (id)initWithRect:(CGRect)rect
{
    self = [super init];
    if ( !self )
    {
        return nil;
    }

    // Register messages broadcasted by the lifebar handler
    REG_MESSAGE(kLifeBarDrainedMessage, @"LifeBarDrained");
    REG_MESSAGE(kLifeBarWarningMessage, @"LifeBarWarning");
    REG_MESSAGE(kLifeBarBackNormalMessage, @"LifeBarRecovered");

    // Creates a simple animation on start of game
    m_fCurrentValue = 0.0f;
    m_fNewValue = 0.5f;

    m_fCurOffset = 0.0f;

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
    m_fNewValue += value;
    if ( m_fNewValue > 1.0 )
    {
        m_fNewValue = 1.0f;
    }
    else if ( m_fNewValue < 0.0 )
    {
        m_fNewValue = 0.0f;
    }
}

/* TMRenderable method */
- (void)render:(float)fDelta
{
    CGRect bounds = [DisplayUtil getDeviceDisplayBounds];
    CGRect fillRect = CGRectMake(m_rShape.origin.x, m_rShape.origin.y, m_rShape.size.width * m_fCurrentValue, m_rShape.size.height);

    // Background first
    [t_LifeBarBG drawInRect:m_rShape];

    glScissor((GLint) fillRect.origin.x,
            (GLint) fillRect.origin.y,
            (GLsizei) fillRect.size.width,
            (GLsizei) fillRect.size.height);
    glEnable(GL_SCISSOR_TEST);

    if ( m_fNewValue < 0.3f )
    {
        // Show passing bar
        [t_LifeBarPassing drawRepeatedInRect:m_rShape withXOffset:m_fCurOffset andYOffset:0.0f];
    }
    else if ( m_fNewValue < 1.0f )
    {
        // Show normal bar
        [t_LifeBarNormal drawRepeatedInRect:m_rShape withXOffset:m_fCurOffset andYOffset:0.0f];
    }
    else
    {
        // Show hot only if we are very good and having full lifebar
        [t_LifeBarHot drawRepeatedInRect:m_rShape withXOffset:m_fCurOffset andYOffset:0.0f];
    }

    glDisable(GL_SCISSOR_TEST);
    glScissor(0, 0, bounds.size.width, bounds.size.height);

    glEnable(GL_BLEND);
    [t_LifeBarFrame drawInRect:m_rShape];
    glDisable(GL_BLEND);
}

/* TMLogicUpdater method */
- (void)update:(float)fDelta
{
    float val = fmaxf(fabsf(m_fNewValue-m_fCurrentValue), 0.05f);
    m_fCurrentValue = TM_LERP(m_fCurrentValue, m_fNewValue, val);

    float currentBeat, currentBps;
    BOOL hasFreeze;

    if ( g_pGameState->m_bPlayingGame )
    {
        [TimingUtil getBeatAndBPSFromElapsedTime:g_pGameState->m_dElapsedTime beatOut:&currentBeat bpsOut:&currentBps freezeOut:&hasFreeze inSong:g_pGameState->m_pSong];
    }

    if ( !hasFreeze )
    {
        m_fCurOffset += currentBps * (1.0 / m_rShape.size.width * 64) * fDelta;

        if ( m_fCurOffset >= m_rShape.size.width )
        {
            m_fCurOffset -= m_rShape.size.width;
        }
    }

    // Check current value
    if ( !m_bWarningBroadcasted && m_fNewValue <= 0.3f )
    {
        BROADCAST_MESSAGE(kLifeBarWarningMessage, nil);
        m_bWarningBroadcasted = YES;
    }
    else if ( m_bWarningBroadcasted && m_fNewValue > 0.3f )
    {
        BROADCAST_MESSAGE(kLifeBarBackNormalMessage, nil);
        m_bWarningBroadcasted = NO;
    }

    if ( m_fNewValue < kMinLifeToKeepAlive && m_bIsActive )
    {
        BROADCAST_MESSAGE(kLifeBarDrainedMessage, nil);

        m_fNewValue = 0.0f;    // Drop to zero
        m_fCurrentValue = 0.0f;
        m_bIsActive = NO;
    }
}

/* TMMessageSupport stuff */
- (void)handleMessage:(TMMessage *)message
{
    if ( !m_bIsActive )
    {
        return;
    }

    switch ( message.messageId )
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
