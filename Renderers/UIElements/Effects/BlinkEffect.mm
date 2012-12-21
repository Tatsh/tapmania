//
//  $Id$
//  BlinkEffect.m
//
//  Created by Alex Kremer on 17.02.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "BlinkEffect.h"
#import "TapMania.h"
#import "EAGLView.h"

@implementation BlinkEffect

- (id)initWithRenderable:(id)renderable
{
    self = [super initWithRenderable:renderable];
    if (!self)
        return nil;

    m_nState = kBlinkOff;
    m_fBlinkTime = 0.0f;

    return self;
}

/* TMRenderable stuff */
- (void)render:(float)fDelta
{
    [super render:fDelta];    // Render stuff

    if (m_nState == kBlinkOn)
    {

        GLfloat vertices[] = {
                m_rShape.origin.x, m_rShape.origin.y,
                m_rShape.origin.x + m_rShape.size.width, m_rShape.origin.y,
                m_rShape.origin.x, m_rShape.origin.y + m_rShape.size.height,
                m_rShape.origin.x + m_rShape.size.width, m_rShape.origin.y + m_rShape.size.height
        };

        glColor4f(0.0f, 0.0f, 0.0f, 0.5f);

        glDisable(GL_TEXTURE_2D);
        glEnable(GL_BLEND);

        glVertexPointer(2, GL_FLOAT, 0, vertices);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        glDisable(GL_BLEND);
        glEnable(GL_TEXTURE_2D);

        glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    }
}


/* TMLogicUpdater stuff */
- (void)update:(float)fDelta
{
    [super update:fDelta];

    if (m_nState == kBlinkWaiting)
    {
        m_fBlinkTime += fDelta;

        if (m_fBlinkTime >= kBlinkWaitTime)
        {
            m_fBlinkTime = 0.0f;
            m_nState = kBlinkOn;
        }

    } else if (m_nState == kBlinkOn)
    {
        // Time to blink!
        m_fBlinkTime += fDelta;

        if (m_fBlinkTime >= kBlinkOnTime)
        {
            m_fBlinkTime = 0.0f;
            m_nState = kBlinkWaiting;
        }
    }
}

/* TMGameUIResponder stuff */
- (BOOL)tmTouchesBegan:(const TMTouchesVec&)touches withEvent:(UIEvent *)event
{
    TMTouch touch = touches.at(0);
    CGPoint point = CGPointMake(touch.x(), touch.y());

    if (CGRectContainsPoint(m_rShape, point))
    {
        m_nState = kBlinkWaiting;
        m_fBlinkTime = 0.0f;
    }

    return [m_idDecoratedObject tmTouchesBegan:touches withEvent:event];

}

- (BOOL)tmTouchesMoved:(const TMTouchesVec&)touches withEvent:(UIEvent *)event
{
    TMTouch touch = touches.at(0);
    CGPoint point = CGPointMake(touch.x(), touch.y());

    if (CGRectContainsPoint(m_rShape, point))
    {
        m_nState = kBlinkWaiting;
    } else
    {
        m_nState = kBlinkOff;
    }

    return [m_idDecoratedObject tmTouchesMoved:touches withEvent:event];
}

- (BOOL)tmTouchesEnded:(const TMTouchesVec&)touches withEvent:(UIEvent *)event
{
    TMTouch touch = touches.at(0);
    CGPoint point = CGPointMake(touch.x(), touch.y());

    if (CGRectContainsPoint(m_rShape, point))
    {
        m_nState = kBlinkOff;
    }

    return [m_idDecoratedObject tmTouchesEnded:touches withEvent:event];
}

@end