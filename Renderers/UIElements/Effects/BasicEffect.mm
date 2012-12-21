//
//  $Id$
//  BasicEffect.m
//  TapMania
//
//  Created by Alex Kremer on 17.02.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "BasicEffect.h"
#import "TMEffectSupport.h"
#import "TMLogicUpdater.h"
#import "TMRenderable.h"

@implementation BasicEffect

- (id)initWithRenderable:(id)renderable
{
    if (![renderable conformsToProtocol:@protocol(TMEffectSupport)])
    {
        NSException *ex = [NSException exceptionWithName:@"Not conforming to TMEffectSupport"
                                                  reason:@"The object you tried to wrapp doesn't conform to the TMEffectSupport protocol." userInfo:nil];
        @throw ex;
    }

    self = [super init];
    if (!self)
        return nil;

    m_idDecoratedObject = renderable;
    m_rOriginalShape = [renderable getShape];
    m_rShape = m_rOriginalShape;

    return self;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    SEL aSelector = [invocation selector];

    if ([m_idDecoratedObject respondsToSelector:aSelector])
    {
        [invocation invokeWithTarget:m_idDecoratedObject];
    } else
    {
        [self doesNotRecognizeSelector:aSelector];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector])
    {
        return YES;
    }

    if ([m_idDecoratedObject respondsToSelector:aSelector])
    {
        return YES;
    }

    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *sig = [super methodSignatureForSelector:aSelector];

    if (!sig)
    {
        sig = [m_idDecoratedObject methodSignatureForSelector:aSelector];
    }

    return sig;
}

- (void)dealloc
{
    [m_idDecoratedObject release];
    [super dealloc];
}

/* TMLogicUpdater stuff */
- (void)update:(float)fDelta
{
    // do effect actions prior to updating the decorated object

    if ([m_idDecoratedObject conformsToProtocol:@protocol(TMLogicUpdater)])
    {
        [m_idDecoratedObject update:fDelta];
    }

    // do effect actions after updating the decorated object
}


/* TMRenderable stuff */
- (void)render:(float)fDelta
{
    // do effect actions prior to drawing the decorated object
    m_rOriginalShape = [m_idDecoratedObject getShape];
    [m_idDecoratedObject updateShape:m_rShape];    // Set it to our effect shape temporary

    if ([m_idDecoratedObject conformsToProtocol:@protocol(TMRenderable)])
    {
        [m_idDecoratedObject render:fDelta];
    }

    // do effect actions after drawing the decorated object
    [m_idDecoratedObject updateShape:m_rOriginalShape];    // Get the original one back
}

/* TMEffectSupport stuff */
- (CGPoint)getPosition
{
    return m_rShape.origin;
}

- (void)updatePosition:(CGPoint)point
{
    m_rShape.origin.x = point.x;
    m_rShape.origin.y = point.y;
}

- (CGRect)getShape
{
    return m_rShape;
}

- (void)updateShape:(CGRect)shape
{
    m_rShape.origin = shape.origin;
    m_rShape.size = shape.size;
}

/* TMGameUIResponder stuff */
- (BOOL)tmTouchesBegan:(const TMTouchesVec&)touches withEvent:(UIEvent *)event
{
    return [m_idDecoratedObject tmTouchesBegan:touches withEvent:event];
}

- (BOOL)tmTouchesMoved:(const TMTouchesVec&)touches withEvent:(UIEvent *)event
{
    return [m_idDecoratedObject tmTouchesMoved:touches withEvent:event];
}

- (BOOL)tmTouchesEnded:(const TMTouchesVec&)touches withEvent:(UIEvent *)event
{
    return [m_idDecoratedObject tmTouchesEnded:touches withEvent:event];
}

@end
