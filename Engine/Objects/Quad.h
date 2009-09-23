//
//  Quad.h
//  TapMania
//
//  Created by Alex Kremer on 23.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

/*
 * The quad is basically a generated texture. We create a Texture object in OpenGLES
 * and simply work with it as of it were a surface to draw on. Later you can draw
 * the contents of this quad as a regular texture in OpenGL.
 */

@interface Quad : NSObject {
	int			m_nWidth, m_nHeight;
}

- (id) initWithWidth:(int)inWidth andHeight:(int)inHeight;

// Drawing onto the quad


// Drawing the quad to the screen
- (void) drawInRect:(CGRect)inRect;
- (void) drawInRect:(CGRect)inRect rotation:(float)inRotation;

@end
