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
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>


/// Cache aware version of glBindTexture
void TMBindTexture(unsigned int tex) {
	static unsigned int currentBind = 0;

	if(currentBind != tex) {
		glBindTexture(GL_TEXTURE_2D, tex);
	}
	
	currentBind = tex;
}