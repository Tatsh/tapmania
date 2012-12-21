//
//  $Id$
//  LifeBar.h
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMLogicUpdater.h"
#import "TMRenderable.h"
#import "TMMessageSupport.h"

#define kMinLifeToKeepAlive 0.03    // TODO: move to metrics

@class Texture2D;

@interface LifeBar : NSObject <TMRenderable, TMLogicUpdater, TMMessageSupport>
{
    float m_fCurrentValue;  // 0.0 -> 100.0 :: defaults to 50.0 on song start
    BOOL m_bIsActive;
    BOOL m_bWarningBroadcasted;
    CGRect m_rShape;    // The rect where the lifebar is drawn

    /* Textures */
    Texture2D *t_LifeBarBG, *t_LifeBarNormal, *t_LifeBarPassing, *t_LifeBarHot, *t_LifeBarFrame;
}

- (id)initWithRect:(CGRect)rect;

- (float)getCurrentValue;

@end
