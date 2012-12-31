//
//	$Id$
//  CDTitleDisplay.mm
//  TapMania
//
//  Created by Alex Kremer on 31.12.12.
//  Copyright 2012 Godexsoft. All rights reserved.
//
//  Happy new year :D
//

#import "CDTitleDisplay.h"
#import "TMSong.h"
#import "ThemeManager.h"
#import "Texture2D.h"

@implementation CDTitleDisplay
{
    CGPoint mt_point;
    float m_rotation;
}

- (id)initWithMetrics:(NSString *)metricsKey
{
    self = [super init];
    if (!self)
        return nil;

    // Cache metrics
    mt_point = POINT_METRIC(metricsKey);
    
    m_rotation = 0.0f;

    return self;
}

- (void)updateWithSong:(TMSong *)song
{
    m_rotation = 0.0f;
    m_pCurSong = song;
}

/* TMRenderable method */
- (void)render:(float)fDelta
{
    if (m_pCurSong.cdTitleTexture != nil)
    {
        glPushMatrix();
        glTranslatef(mt_point.x, mt_point.y, 0.0);
        glRotatef(m_rotation, 0, 1, 0);

        // make it a bit darker if we are looking at the back of the texture
        if(m_rotation > 90.0f && m_rotation < 270.0f)
        {
            glColor4f(0.1, 0.1, 0.1, 0.8);
        }

        [m_pCurSong.cdTitleTexture drawAtPoint:CGPointZero];

        if(m_rotation > 90.0f && m_rotation < 270.0f)
        {
            glColor4f(1, 1, 1, 1);
        }

        glPopMatrix();
    }
}

/* TMLogicUpdater method */
- (void)update:(float)fDelta
{
    m_rotation += 360.0f * fDelta;
    if (m_rotation > 360.0f)
    {
        m_rotation = 360.0f-m_rotation;
    }
}

- (void)dealloc
{
    [super dealloc];
}

@end
