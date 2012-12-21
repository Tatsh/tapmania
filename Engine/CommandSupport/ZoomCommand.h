//
//  $Id$
//  ZoomCommand.h
//  TapMania
//
//  Created by Alex Kremer on 28.10.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMCommand.h"

@interface ZoomCommand : TMCommand
{
    float m_fElapsedTime;
    float m_fZoomTime;        // Effect time in seconds

    float m_fCurrentRatio;    // Zoom progress
    float m_fRatio;            // The requested ratio
    CGRect m_OriginalShape;    // Save the original size of the object
}

@end
