//
//	$Id$
//  ComboMeter.mm
//  TapMania
//
//  Created by Alex Kremer on 25.01.10.
//  Copyright 2010 Godexsoft. All rights reserved.
//

#import "ComboMeter.h"
#import "TMNote.h"
#import "Judgement.h"

#import "ThemeManager.h"

#import "MessageManager.h"
#import "TMMessage.h"

#import "FontString.h"

#import "GameState.h"

extern TMGameState *g_pGameState;

@implementation ComboMeter

- (id)initWithMetrics:(NSString *)metricsKey
{
    self = [super init];
    if ( !self )
    {
        return nil;
    }

    // Cache metrics
    mt_ComboMeter = POINT_METRIC(metricsKey);

    SUBSCRIBE(kNoteScoreMessage);
    m_nCombo = m_nMaxComboSoFar = 0;

    // Get the font
    m_pComboStr = [[FontString alloc] initWithFont:@"Combo numbers" andText:@"0"];

    // A simple image
    m_pComboTexture = TEXTURE(metricsKey);
    mt_ComboStr = CGPointMake(mt_ComboMeter.x - m_pComboTexture.contentSize.width / 2, mt_ComboMeter.y);

    return self;
}

- (int)getMaxCombo
{
    return m_nMaxComboSoFar;
}

/* TMMessageSupport stuff */
- (void)handleMessage:(TMMessage *)message
{
    switch ( message.messageId )
    {
        case kNoteScoreMessage:

            TMNote *note = (TMNote *) message.payload;

            if ( note.m_nScore > kJudgementW3 )
            {
                m_nCombo = 0;
            }
            else
            {
                m_nMaxComboSoFar = (++m_nCombo > m_nMaxComboSoFar ? m_nCombo : m_nMaxComboSoFar);

                [m_pComboStr updateText:[NSString stringWithFormat:@"%d", m_nCombo]];
            }

            g_pGameState->m_nCombo = m_nCombo;

            break;
    }
}

/* TMRenderable method */
- (void)render:(float)fDelta
{
    if ( !g_pGameState->m_bIsGlobalSync )
    {
        if ( m_nCombo > 4 )
        {
            glEnable(GL_BLEND);
            [m_pComboTexture drawAtPoint:mt_ComboStr];
            [m_pComboStr drawAtPoint:mt_ComboMeter];
            glDisable(GL_BLEND);
        }
    }
}

/* TMLogicUpdater method */
- (void)update:(float)fDelta
{

}

- (void)dealloc
{
    UNSUBSCRIBE_ALL();
    [m_pComboStr release];
    [super dealloc];
}

@end
