//
//  $Id$
//  BlinkEffect.h
//  TapMania
//
//  Created by Alex Kremer on 17.02.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "BasicEffect.h"

typedef enum
{
    kBlinkOff = 0,
    kBlinkWaiting,
    kBlinkOn
} TMBlinkEffectState;

#define        kBlinkOnTime    0.1
#define        kBlinkWaitTime    0.9

@interface BlinkEffect : BasicEffect
{
    float m_fBlinkTime;    // Time since last blink
    TMBlinkEffectState m_nState;
}

@end
