//
//  $Id$
//  FPS.h
//  TapMania
//
//  Created by Alex Kremer on 13.02.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMControl.h"

@class Texture2D;

@interface FPS : TMControl
{
    long m_lFpsCounter;
    double m_dTimeCounter;

    Texture2D *m_pCurrentTexture;
}

@end
