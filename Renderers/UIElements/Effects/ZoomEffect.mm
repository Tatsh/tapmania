//
//  $Id$
//  ZoomEffect.m
//  TapMania
//
//  Created by Alex Kremer on 17.02.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "ZoomEffect.h"
#import "TapMania.h"
#import "EAGLView.h"

@implementation ZoomEffect

- (id)initWithRenderable:(id)renderable
{
    self = [super initWithRenderable:renderable];
    if (!self)
        return nil;

    m_fCurrentValue = 0.0f;
    m_nState = kZoomNone;

    return self;
}

/* TMLogicUpdater stuff */
- (void)update:(float)fDelta
{
    [super update:fDelta];

    if (m_nState == kZoomIn)
    {

        m_fCurrentValue += kZoomStep;

        if (m_fCurrentValue >= kMaxZoomLevel)
        {
            m_fCurrentValue = kMaxZoomLevel;
            m_nState = kZoomNone;
        }

    } else if (m_nState == kZoomOut)
    {
        m_fCurrentValue -= kZoomStep;

        if (m_fCurrentValue <= 0.0f)
        {
            m_fCurrentValue = 0.0f;
            m_nState = kZoomNone;
        }
    }

    if (m_nState != kZoomNone)
    {
        CGRect decoratedShape = [m_idDecoratedObject getShape];
        m_rShape = CGRectMake(decoratedShape.origin.x - m_fCurrentValue, decoratedShape.origin.y - m_fCurrentValue,
                decoratedShape.size.width + (m_fCurrentValue * 2), decoratedShape.size.height + (m_fCurrentValue * 2));
    }

}

/* TMGameUIResponder stuff */
- (BOOL)tmTouchesBegan:(const TMTouchesVec&)touches withEvent:(UIEvent *)event
{
    TMTouch touch = touches.at(0);
    CGPoint point = CGPointMake(touch.x(), touch.y());

    if (CGRectContainsPoint(m_rShape, point))
    {
        m_nState = kZoomIn;
    }

    return [m_idDecoratedObject tmTouchesBegan:touches withEvent:event];
}

- (BOOL)tmTouchesMoved:(const TMTouchesVec&)touches withEvent:(UIEvent *)event
{
    TMTouch touch = touches.at(0);
    CGPoint point = CGPointMake(touch.x(), touch.y());

    if (CGRectContainsPoint(m_rShape, point))
    {
        m_nState = kZoomIn;
    } else
    {
        m_nState = kZoomOut;
    }

    return [m_idDecoratedObject tmTouchesMoved:touches withEvent:event];
}

- (BOOL)tmTouchesEnded:(const TMTouchesVec&)touches withEvent:(UIEvent *)event
{
    TMTouch touch = touches.at(0);
    CGPoint point = CGPointMake(touch.x(), touch.y());

    if (CGRectContainsPoint(m_rShape, point))
    {
        m_nState = kZoomOut;
    }

    return [m_idDecoratedObject tmTouchesEnded:touches withEvent:event];
}

@end
