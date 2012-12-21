//
//  $Id$
//  TapMine.mm
//  TapMania
//
//  Created by Alex Kremer on 18.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TapMine.h"


@implementation TapMine

// Override TMAnimatable constructor
- (id)initWithImage:(UIImage *)uiImage columns:(int)columns andRows:(int)rows
{
    self = [super initWithImage:uiImage columns:columns andRows:rows];
    if (!self)
        return nil;

    // We will animate every mine at same time
    m_nStartFrame = 0;
    m_nEndFrame = columns * rows;

    m_nCurrentFrame = m_nStartFrame;
    m_bIsLooping = YES;

    return self;
}

/* Main drawing routine */
- (void)drawTapMineInRect:(CGRect)rect
{
    glEnable(GL_BLEND);
    [self drawFrame:m_nCurrentFrame inRect:rect];
    glDisable(GL_BLEND);
}

@end
