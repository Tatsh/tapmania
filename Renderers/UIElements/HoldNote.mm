//
//  $Id$
//  HoldNote.m
//  TapMania
//
//  Created by Alex Kremer on 10.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "HoldNote.h"
#import "ThemeManager.h"
#include "GLUtil.h"

@implementation HoldNote

- (id)initWithImage:(UIImage *)uiImage columns:(int)columns andRows:(int)rows
{
    self = [super initWithImage:uiImage columns:columns andRows:rows];
    if (!self)
        return nil;

    mt_HoldBody = SIZE_SKIN_METRIC(@"HoldNote Body");

    return self;
}

- (void)drawBodyPieceWithSize:(CGFloat)size atPoint:(CGPoint)point
{
    // Size is the size in pixels to crop the texture from the bottom of it

    float minTextureFromSize = m_fMaxT - (m_fMaxT * (size / mt_HoldBody.height));

    GLfloat coordinates[] = {
            0, m_fMaxT,
            m_fMaxS, m_fMaxT,
            0, minTextureFromSize,
            m_fMaxS, minTextureFromSize
    };

    GLfloat width = mt_HoldBody.width,
            height = size;

    GLfloat vertices[] = {
            point.x, point.y, 0.0,
            point.x + width, point.y, 0.0,
            point.x, point.y + height, 0.0,
            point.x + width, point.y + height, 0.0
    };

    glEnable(GL_BLEND);
    TMBindTexture(m_unName);
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisable(GL_BLEND);
}

@end
