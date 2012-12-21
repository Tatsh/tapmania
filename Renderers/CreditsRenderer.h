//
//  $Id$
//  CreditsRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMScreen.h"

@class TMRunLoop;

@interface CreditsRenderer : TMScreen
{
    NSMutableArray *m_aTexturesArray;

    BOOL m_bShouldReturn;
    float m_fCurrentPos; // Current Y coordinate of the scrolling text
}

@end
