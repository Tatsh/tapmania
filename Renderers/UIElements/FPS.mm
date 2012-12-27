//
//  $Id$
//  FPS.m
//  TapMania
//
//  Created by Alex Kremer on 13.02.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "FPS.h"
#import "DisplayUtil.h"
#import "FontString.h"

@implementation FPS

- (id)init
{
    self = [super initWithShape:CGRectMake(0, 0, [DisplayUtil getDeviceDisplaySize].width, 20)];
    if (!self)
        return nil;

    m_lFpsCounter = 0;
    m_dTimeCounter = 0.0;

    m_pFpsStr = [[FontString alloc] initWithFont:@"Common FPS" andText:@"FPS: 0"];
    [m_pFpsStr setAlignment:UITextAlignmentLeft];

    return self;
}

/* TMRenderable method */
/* Updates are also done here because we actually want to count drawing only */
- (void)render:(float)fDelta
{
    m_dTimeCounter += fDelta;

    if (m_dTimeCounter > 1.0f)
    {
        m_lFpsCounter /= m_dTimeCounter;

        [m_pFpsStr updateText:[NSString stringWithFormat:@"FPS: %ld", m_lFpsCounter]];

        m_dTimeCounter = 0.0;
        m_lFpsCounter = 0;
    }

    ++m_lFpsCounter;
    [m_pFpsStr drawAtPoint:CGPointMake(1, 16)];
}

- (void)dealloc
{
    [m_pFpsStr release];
    [super dealloc];
}

@end
