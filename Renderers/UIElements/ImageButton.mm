//
//  $Id$
//  ImageButton.m
//  TapMania
//
//  Created by Alex Kremer on 5/27/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "ImageButton.h"
#import "ThemeManager.h"
#import "Texture2D.h"

@implementation ImageButton

- (id)initWithTexture:(Texture2D *)tex andShape:(CGRect)shape
{
    self = [super initWithShape:shape];
    if (!self)
        return nil;

    m_pTexture = tex;

    return self;
}

- (id)initWithMetrics:(NSString *)inMetricsKey
{
    self = [super initWithShape:RECT_METRIC(inMetricsKey)];
    if (!self)
        return nil;

    // Get graphics and sounds used by this control
    [self initGraphicsAndSounds:inMetricsKey];

    // Add commands support
    [super initCommands:inMetricsKey];

    return self;
}

- (void)initGraphicsAndSounds:(NSString *)inMetricsKey
{
    [super initGraphicsAndSounds:inMetricsKey];

    // Load texture
    m_pTexture = (Texture2D *) [[ThemeManager sharedInstance] texture:inMetricsKey];
}


/* TMRenderable stuff */
- (void)render:(float)fDelta
{
    if (m_bVisible)
    {
        glEnable(GL_BLEND);
        [m_pTexture drawInRect:m_rShape];
        glDisable(GL_BLEND);
    }
}

@end
