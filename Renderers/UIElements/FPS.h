//
//  $Id$
//  FPS.h
//  TapMania
//
//  Created by Alex Kremer on 13.02.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMControl.h"

@class FontString;

@interface FPS : TMControl
{
    long m_lFpsCounter;
    double m_dTimeCounter;

    FontString * m_pFpsStr;
}

@end
