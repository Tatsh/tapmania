/*
 *  GLUtil.mm
 *  TapMania
 *
 *  Created by Alex Kremer on 21.01.10.
 *  Copyright 2010 Godexsoft. All rights reserved.
 *
 *	$Id$
 */

#include "GLUtil.h"
#include <OpenGLES/ES1/glext.h>


/// Cache aware version of glBindTexture
void TMBindTexture(GLuint tex)
{
    static GLuint currentId = 0;

    if (currentId != tex)
    {
        currentId = tex;
        glBindTexture(GL_TEXTURE_2D, currentId);
    }
}