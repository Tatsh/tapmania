//
//  $Id$
//  SleepCommand.mm
//  TapMania
//
//  Created by Alex Kremer on 23.10.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "SleepCommand.h"
#import "TapMania.h"

@implementation SleepCommand

- (id)initWithArguments:(NSArray *)inArgs andInvocationObject:(NSObject *)inObj
{
    self = [super initWithArguments:inArgs andInvocationObject:inObj];
    if (!self)
        return nil;

    if ([inArgs count] != 1)
    {
        TMLog(@"Wrong argument count for command 'sleep'. abort.");
        return nil;
    }

    m_fElapsedTime = 0.0f;
    NSObject *value = [self getValueFromString:[m_aArguments objectAtIndex:0] withObject:m_pInvocationObject];

    if (value)
    {
        m_fTimeToWait = [(NSNumber *) value floatValue];
    } else
    {
        return nil;
    }

    return self;
}

/* TMLogicUpdater stuff */
- (void)update:(float)fDelta
{
    m_fElapsedTime += fDelta;

    if (m_fElapsedTime >= m_fTimeToWait)
    {
        TMLog(@"TIMER DONE... sleep,%f", m_fTimeToWait);
        [self invokeOnObject:m_pInvocationObject];

        // FIXME: release?
        [[TapMania sharedInstance] deregisterObject:self];
    }
}

- (void)setTimeToWait:(float)fVal
{
    m_fTimeToWait = fVal;
}

@end
