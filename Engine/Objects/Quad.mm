//
//  $Id$
//  Quad.mm
//  TapMania
//
//  Created by Alex Kremer on 23.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "Quad.h"
#import <OpenGLES/ES1/glext.h>
#import "TMFramedTexture.h"
#include "GLUtil.h"
#import "TMSprite.h"

@implementation Quad

- (id)initWithWidth:(NSUInteger)inWidth andHeight:(NSUInteger)inHeight
{
    GLint saveName;
    BOOL sizeToFit = NO;
    int i = 0;

    if ((self = [super init]))
    {
        glGenTextures(1, &m_unName);
        glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
        TMBindTexture(m_unName);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

        m_oSize = CGSizeMake(inWidth, inHeight);
        m_unWidth = inWidth;
        m_unHeight = inHeight;

        if ((m_unWidth != 1) && (m_unWidth & (m_unWidth - 1)))
        {
            i = 1;
            while ((sizeToFit ? 2 * i : i) < m_unWidth)
                i *= 2;
            m_unWidth = i;
        }

        m_unHeight = m_oSize.height;
        if ((m_unHeight != 1) && (m_unHeight & (m_unHeight - 1)))
        {
            i = 1;
            while ((sizeToFit ? 2 * i : i) < m_unHeight)
                i *= 2;
            m_unHeight = i;
        }

        // empty data
        void *data = (void *) calloc(m_unWidth * m_unHeight * 4, sizeof(GLubyte));

        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, m_unWidth, m_unHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, (void *) data);
        TMBindTexture(saveName);

        m_fMaxS = m_oSize.width / (float) m_unWidth;
        m_fMaxT = m_oSize.height / (float) m_unHeight;

        TMLog(@"Quad with requestedSize: %dx%d is fitting into %dx%d texture.", inWidth, inHeight, m_unWidth, m_unHeight);

        free(data);
    }

    return self;
}

- (void)renderSprite:(TMSprite *)sprite atPoint:(CGPoint)point
{
    GLuint oldFramebuffer, fbo;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, (GLint *) &oldFramebuffer);

    // generate FBO
    glGenFramebuffersOES(1, &fbo);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, fbo);

    // associate texture with FBO
    glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, m_unName, 0);

    // check if it worked (probably worth doing :) )
    GLuint status = glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES);
    if (status != GL_FRAMEBUFFER_COMPLETE_OES)
    {
        // didn't work
    }

    glBindFramebufferOES(GL_FRAMEBUFFER_OES, fbo);


    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();
    glOrthof(0.0, m_unWidth, 0.0, m_unHeight, -1, 1);
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();

    int viewport[4];
    glGetIntegerv(GL_VIEWPORT, viewport);
    glViewport(0, 0, m_unWidth, m_unHeight);

    glTranslatef(point.x, point.y, 0.0);

    // Copy texels to framebuffer and then to our quad
    glEnable(GL_BLEND);

    [sprite draw];

    glDisable(GL_BLEND);

    // restore
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, oldFramebuffer);
    glDeleteFramebuffersOES(1, &fbo);

    glViewport(viewport[0], viewport[1], viewport[2], viewport[3]);

    glPopMatrix();
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    glMatrixMode(GL_MODELVIEW);
}

- (void)copyFrame:(int)frameId withExtraLeft:(float)pixelsLeft extraRight:(float)pixelsRight
          toPoint:(CGPoint)inPoint fromTexture:(TMFramedTexture *)texture
{
    CGSize frameSize = CGSizeMake(texture.contentSize.width / [texture cols], texture.contentSize.height / [texture rows]);
    GLuint oldFramebuffer, fbo;

    TMLog(@"Frame size = %f/%f", frameSize.width, frameSize.height);

    glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, (GLint *) &oldFramebuffer);

    // generate FBO
    glGenFramebuffersOES(1, &fbo);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, fbo);

    // associate texture with FBO
    glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, m_unName, 0);

    // check if it worked (probably worth doing :) )
    GLuint status = glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES);
    if (status != GL_FRAMEBUFFER_COMPLETE_OES)
    {
        // didn't work
    }

    glBindFramebufferOES(GL_FRAMEBUFFER_OES, fbo);


    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();
    glOrthof(0.0, m_unWidth, 0.0, m_unHeight, -1, 1);
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();

    int viewport[4];
    glGetIntegerv(GL_VIEWPORT, viewport);
    glViewport(0, 0, m_unWidth, m_unHeight);

    // Copy texels to framebuffer and then to our quad
    glEnable(GL_BLEND);

    TMLog(@"Draw frame at %f/%f-%fx%f", inPoint.x, inPoint.y, frameSize.width, frameSize.height);
    [texture drawFrame:frameId withExtraLeft:pixelsLeft extraRight:pixelsRight
                inRect:CGRectMake(inPoint.x - frameSize.width / 2, inPoint.y, frameSize.width, frameSize.height)];

    glDisable(GL_BLEND);

    // restore
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, oldFramebuffer);
    glDeleteFramebuffersOES(1, &fbo);

    glViewport(viewport[0], viewport[1], viewport[2], viewport[3]);

    glPopMatrix();
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    glMatrixMode(GL_MODELVIEW);
}

// Copy a frame of the texture to the given location in the quad
- (void)copyFrame:(int)frameId toPoint:(CGPoint)inPoint fromTexture:(TMFramedTexture *)texture
{
    [self copyFrame:frameId withExtraLeft:0.0f extraRight:0.0f toPoint:inPoint fromTexture:texture];
}


// Drawing of the quad 
- (void)drawAtPoint:(CGPoint)point
{
    GLfloat coordinates[] = {
            0, 0,
            m_fMaxS, 0,
            0, m_fMaxT,
            m_fMaxS, m_fMaxT
    };

    GLfloat width = (GLfloat) m_unWidth * m_fMaxS,
            height = (GLfloat) m_unHeight * m_fMaxT;
    GLfloat vertices[] = {
            -width / 2 + point.x, -height / 2 + point.y, 0.0,
            width / 2 + point.x, -height / 2 + point.y, 0.0,
            -width / 2 + point.x, height / 2 + point.y, 0.0,
            width / 2 + point.x, height / 2 + point.y, 0.0
    };

    TMBindTexture(m_unName);
    glEnable(GL_BLEND);
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisable(GL_BLEND);
}

- (void)drawInRect:(CGRect)rect
{
    GLfloat coordinates[] = {
            0, 0,
            m_fMaxS, 0,
            0, m_fMaxT,
            m_fMaxS, m_fMaxT
    };

    GLfloat vertices[] = {
            rect.origin.x, rect.origin.y, 0.0,
            rect.origin.x + rect.size.width, rect.origin.y, 0.0,
            rect.origin.x, rect.origin.y + rect.size.height, 0.0,
            rect.origin.x + rect.size.width, rect.origin.y + rect.size.height, 0.0
    };

    TMBindTexture(m_unName);
    glEnable(GL_BLEND);
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisable(GL_BLEND);
}

- (void)drawInRect:(CGRect)rect rotation:(float)rotation
{
    glPushMatrix();

    glTranslatef(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2, 0.0);
    glRotatef(rotation, 0, 0, 1);

    [self drawAtPoint:CGPointZero];
    glPopMatrix();
}

@end
