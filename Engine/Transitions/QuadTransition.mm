//
//  $Id$
//  QuadTransition.m
//  TapMania
//
//  Created by Alex Kremer on 13.02.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "QuadTransition.h"
#import "TapMania.h"
#import "EAGLView.h"
#import "TMScreen.h"
#import "DisplayUtil.h"


@implementation QuadTransition

- (id)initFromScreen:(TMScreen *)fromScreen toScreen:(TMScreen *)toScreen
{
    self = [super initFromScreen:fromScreen toScreen:toScreen];
    if (!self)
        return nil;

    m_fRotation = 0.0f;

    return self;
}

// TMRenderable stuff
- (void)render:(float)fDelta
{
    CGSize ds = [DisplayUtil getDeviceDisplaySize];
    GLfloat midX = ds.width / 2.0f;
    GLfloat midY = ds.height / 2.0f;

    GLfloat curOffset = ds.height * m_fTransitionPosition;
    TMLog(@"CurOffset %f", curOffset);

    GLfloat vertices[] = {
            midX - curOffset, midY - curOffset,
            midX + curOffset, midY - curOffset,
            midX - curOffset, midY + curOffset,
            midX + curOffset, midY + curOffset
    };

    glPushMatrix();

    glColor4f(0.0f, 0.0f, 0.0f, m_fTransitionPosition);

    glDisable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glTranslatef(midX, midY, 0.0f);
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glRotatef(m_fRotation, 0.0f, 0.0f, 1.0f);

    glTranslatef(0.0f, 0.0f, 0.0f);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    glDisable(GL_BLEND);
    glEnable(GL_TEXTURE_2D);
    glColor4f(1, 1, 1, 1);

    glPopMatrix();
}

- (BOOL)updateTransitionIn
{
    if (![super updateTransitionIn])
    {
        m_fRotation += 8.0f;
        return NO;
    }

    return YES;
}

- (BOOL)updateTransitionOut
{
    if (![super updateTransitionOut])
    {
        m_fRotation += 8.0f;
        return NO;
    }

    return YES;
}


@end
