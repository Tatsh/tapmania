//
//  $Id$
//  TMScreen.h
//  TapMania
//
//  Created by Alex Kremer on 10.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMTransitionSupport.h"
#import "TMView.h"

@class Texture2D;

/* A screen is a fullscreen view with transition support */
@interface TMScreen : TMView <TMTransitionSupport>
{
    // A screen most likely has a background image
    Texture2D *t_BG;
    float m_fBrightness;    // Background brightness
}

@property(assign) float brightness;

- (void)fade;

- (id)initWithMetrics:(NSString *)inMetricsKey;

@end
