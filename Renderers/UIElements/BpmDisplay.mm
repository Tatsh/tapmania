//
//	$Id$
//  BpmDisplay.mm
//  TapMania
//
//  Created by Alex Kremer on 30.12.12.
//  Copyright 2012 Godexsoft. All rights reserved.
//

#import "BpmDisplay.h"
#import "FontString.h"
#import "TMSong.h"
#import "TMChangeSegment.h"
#import "ThemeManager.h"

@implementation BpmDisplay
{
    int  m_max;
    int  m_min;
    float m_time;
    CGPoint mt_point;
}

- (id)initWithMetrics:(NSString *)metricsKey
{
    self = [super init];
    if (!self)
        return nil;

    // Cache metrics
    mt_point = POINT_METRIC(metricsKey);

    // Get the font
    m_pBpmStr = [[FontString alloc] initWithFont:metricsKey andText:@"BPM 0"];

    return self;
}

- (void)updateWithSong:(TMSong *)song
{
    m_pCurSong = song;

    m_max = 0;
    m_min = INT_MAX;

    int cnt = [m_pCurSong getBpmChangeCount];
    for (int i=0; i<cnt; ++i)
    {
        TMChangeSegment *change = [m_pCurSong getBpmChangeAt:i];
        float bpm = change.m_fChangeValue*60.0f;
        m_min = (int) (m_min<bpm?m_min:bpm);
        m_max = (int) (m_max>bpm?m_max:bpm);
        m_time = 0.0f;
    }
}

/* TMRenderable method */
- (void)render:(float)fDelta
{
    [m_pBpmStr drawAtPoint:mt_point];
}

/* TMLogicUpdater method */
- (void)update:(float)fDelta
{
    int current = m_min;
    if (m_time >= 0.5f && m_time < 1.5f)
    {   
        float thru = m_time-0.5f;
        current = (int) (m_min + thru * (m_max-m_min));
    }
    else if (m_time >= 2.0f && m_time < 3.0f)
    {
        float thru = 1.0f-(m_time-2.0f);
        current = (int) (m_min + thru * (m_max-m_min));
    }
    else if(m_time >= 3.0f)
    {
        m_time = 0.0f;
    }
    else if(m_time >= 1.5f)
    {
        current = m_max;
    }

    [m_pBpmStr updateText:[NSString stringWithFormat:@"BPM %d", current]];
    m_time += fDelta;
}

- (void)dealloc
{
    [m_pBpmStr release];
    [super dealloc];
}

@end
