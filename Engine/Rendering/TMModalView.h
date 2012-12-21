//
//  $Id$
//  TMModalView.h
//  TapMania
//
//  Created by Alex Kremer on 17.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMView.h"

@class Texture2D;

/* A modal view is a floating view (popup, dialog etc.) */
@interface TMModalView : TMView
{
    // A dialog can have a texture background just like a screen
    Texture2D *t_BG;
    float m_fBrightness;    // Background brightness
}

- (id)initWithMetrics:(NSString *)inMetricsKey;

- (void)close;

@end
