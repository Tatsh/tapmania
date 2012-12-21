//
//  $Id$
//  ZoomEffect.h
//  TapMania
//
//  Created by Alex Kremer on 17.02.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "BasicEffect.h"

#define kMaxZoomLevel  5.0
#define kZoomStep       0.5

typedef enum
{
    kZoomNone = 0,
    kZoomIn,
    kZoomOut
} TMZoomEffectState;

@interface ZoomEffect : BasicEffect
{
    float m_fCurrentValue;    // Animation progress (from 0.0 to kMaxZoomLevel)

    TMZoomEffectState m_nState;    // State of the effect
}

@end
