//
//  $Id$
//  SleepCommand.h
//  TapMania
//
//  Created by Alex Kremer on 23.10.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMCommand.h"

@interface SleepCommand : TMCommand
{
    float m_fElapsedTime;
    float m_fTimeToWait;    // Millis
}

- (void)setTimeToWait:(float)fVal;

@end
