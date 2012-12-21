//
//  $Id$
//  ZoomCommand.mm
//  TapMania
//
//  Created by Alex Kremer on 28.10.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "ZoomCommand.h"
#import "TMControl.h"
#import "TapMania.h"

@implementation ZoomCommand

- (id)initWithArguments:(NSArray *)inArgs andInvocationObject:(NSObject *)inObj
{
    self = [super initWithArguments:inArgs andInvocationObject:inObj];
    if (!self)
        return nil;

    if ([inArgs count] != 2)
    {
        TMLog(@"Wrong argument count for command 'zoom'. abort.");
        return nil;
    }

    if (![m_pInvocationObject isKindOfClass:[TMControl class]])
    {
        TMLog(@"Zoom command only supported for TMControl class. abort.");
        return nil;
    }

    m_fElapsedTime = 0.0f;
    m_OriginalShape = [(TMControl *) m_pInvocationObject getOriginalShape];
    NSObject *ratio = [self getValueFromString:[m_aArguments objectAtIndex:0] withObject:m_pInvocationObject];
    NSObject *zTime = [self getValueFromString:[m_aArguments objectAtIndex:1] withObject:m_pInvocationObject];

    if (zTime)
    {
        m_fZoomTime = [(NSNumber *) zTime floatValue];
    } else
    {
        return nil;
    }

    if (ratio)
    {
        m_fRatio = [(NSNumber *) ratio floatValue];
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
    float step = m_fElapsedTime / m_fZoomTime;

    // Calculate current ratio
    m_fCurrentRatio = [(TMControl *) m_pInvocationObject getShape].size.height / m_OriginalShape.size.height;
    m_fCurrentRatio = m_fCurrentRatio + ((m_fRatio - m_fCurrentRatio) * step);
    if (m_fCurrentRatio <= 0.0f)
    {
        m_fCurrentRatio = 0.01f;
    }

    // Set new shape to the control
    CGRect nShape = m_OriginalShape;
    float midX = CGRectGetMidX(nShape);
    float midY = CGRectGetMidY(nShape);

    nShape.size.width *= m_fCurrentRatio;
    nShape.size.height *= m_fCurrentRatio;
    nShape.origin.x = midX - nShape.size.width / 2;
    nShape.origin.y = midY - nShape.size.height / 2;

    [(TMControl *) m_pInvocationObject updateShape:nShape];

    if (m_fElapsedTime >= m_fZoomTime)
    {
        TMLog(@"Zoom command done after %f", m_fZoomTime);
        [self invokeOnObject:m_pInvocationObject];
        [[TapMania sharedInstance] deregisterObject:self];
    }
}

@end
