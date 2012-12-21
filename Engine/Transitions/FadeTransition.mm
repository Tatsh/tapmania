//
//  $Id$
//  FadeTransition.m
//  TapMania
//
//  Created by Alex Kremer on 11.02.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "FadeTransition.h"
#import "TapMania.h"
#import "ThemeManager.h"
#import "EAGLView.h"
#import "TMScreen.h"
#import "DisplayUtil.h"

@implementation FadeTransition

- (id)initFromScreen:(TMScreen *)fromScreen toScreen:(TMScreen *)toScreen
{
    self = [super initFromScreen:fromScreen toScreen:toScreen];
    if (!self)
        return nil;

    m_fTransitionPosition = 0.0f;

    return self;
}


// TMRenderable stuff
- (void)render:(float)fDelta
{
    CGRect rect = [DisplayUtil getDeviceDisplayBounds];
    GLfloat vertices[] = {
            rect.origin.x, rect.origin.y,
            rect.origin.x + rect.size.width, rect.origin.y,
            rect.origin.x, rect.origin.y + rect.size.height,
            rect.origin.x + rect.size.width, rect.origin.y + rect.size.height
    };

    glColor4f(0.0f, 0.0f, 0.0f, m_fTransitionPosition);

    glDisable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisable(GL_BLEND);
    glEnable(GL_TEXTURE_2D);

    glColor4f(1, 1, 1, 1);
}

- (BOOL)updateTransitionIn
{
    [super updateTransitionIn];

    m_fTransitionPosition = m_dElapsedTime / m_dTimeIn;

    if (m_fTransitionPosition >= 1.0f)
    {
        m_fTransitionPosition = 1.0f;

        return YES; // Ready
    }

    return NO; // Busy
}

- (BOOL)updateTransitionOut
{
    [super updateTransitionOut];

    m_fTransitionPosition = 1.0f - m_dElapsedTime / m_dTimeOut;

    if (m_fTransitionPosition <= 0.0f)
    {
        m_fTransitionPosition = 0.0f;

        return YES; // Ready
    }

    return NO; // Busy
}

@end
