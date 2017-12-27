//
//  $Id$
//  InputEngine.m
//  TapMania
//
//  Created by Alex Kremer on 03.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "InputEngine.h"
#import "TMGameUIResponder.h"
#import "TMTouch.h"
#import "TapMania.h"
#import "DisplayUtil.h"

// This is a singleton class, see below
static InputEngine *sharedInputEngineDelegate = nil;

@interface InputEngine (Private)
- (TMTouchesVec)applyTransform:(NSSet *)touches;
@end


@implementation InputEngine

- (id)init
{
    self = [super init];
    if (!self)
        return nil;

    m_aSubscribers = [[NSMutableArray alloc] initWithCapacity:5];
    m_bDispatcherEnabled = YES;

    return self;
}

- (void)disableDispatcher
{
    m_bDispatcherEnabled = NO;
}

- (void)enableDispatcher
{
    m_bDispatcherEnabled = YES;
}

- (void)subscribe:(id <TMGameUIResponder>)handler
{
    [m_aSubscribers addObject:handler];
}

- (void)unsubscribe:(id <TMGameUIResponder>)handler
{
    // Will remove the handler if found
    [m_aSubscribers removeObject:handler];
}

- (TMTouchesVec)applyTransform:(NSSet *)touches
{
    TMTouchesVec tmTouches;

    for (UITouch *touch in touches)
    {
        CGPoint pos = [touch locationInView:nil];
        CGPoint opos = [touch previousLocationInView:nil];

        if ([DisplayUtil isRetina])
        {
            opos.x *= 2.0f;
            opos.y *= 2.0f;

            pos.x *= 2.0f;
            pos.y *= 2.0f;
        }

        pos = CGPointApplyAffineTransform(pos, [TapMania sharedInstance].m_InputTransform);
        opos = CGPointApplyAffineTransform(opos, [TapMania sharedInstance].m_InputTransform);

        tmTouches.push_back(TMTouch(pos.x, pos.y, opos.x, opos.y, (unsigned int)touch.tapCount, touch.timestamp));
    }

    return tmTouches;
}

- (void)dispatchTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (m_bDispatcherEnabled)
    {
        TMTouchesVec tmTouches = [self applyTransform:touches];

        NSInteger i;
        for (i = static_cast<NSInteger>([m_aSubscribers count]) - 1; i >= 0; --i)
        {
            id <TMGameUIResponder> handler = m_aSubscribers[static_cast<NSUInteger>(i)];

            if ([handler tmTouchesBegan:tmTouches withEvent:event])
            {
                return;
            }
        }
    }
}

- (void)dispatchTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (m_bDispatcherEnabled)
    {
        TMTouchesVec tmTouches = [self applyTransform:touches];

        NSInteger i;
        for (i = static_cast<NSInteger>([m_aSubscribers count]) - 1; i >= 0; --i)
        {
            id <TMGameUIResponder> handler = m_aSubscribers[static_cast<NSUInteger>(i)];

            if ([handler tmTouchesMoved:tmTouches withEvent:event])
            {
                return;
            }
        }
    }
}

- (void)dispatchTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (m_bDispatcherEnabled)
    {
        TMTouchesVec tmTouches = [self applyTransform:touches];

        NSInteger i;
        for (i = static_cast<NSInteger>([m_aSubscribers count]) - 1; i >= 0; --i)
        {
            id <TMGameUIResponder> handler = m_aSubscribers[static_cast<NSUInteger>(i)];

            if ([handler tmTouchesEnded:tmTouches withEvent:event])
            {
                return;
            }
        }
    }
}

#pragma mark Singleton stuff

+ (InputEngine *)sharedInstance
{
    @synchronized (self)
    {
        if (sharedInputEngineDelegate == nil)
        {
            (void)[[self alloc] init];
        }
    }
    return sharedInputEngineDelegate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized (self)
    {
        if (sharedInputEngineDelegate == nil)
        {
            sharedInputEngineDelegate = [super allocWithZone:zone];
            return sharedInputEngineDelegate;
        }
    }

    return nil;
}


@end
