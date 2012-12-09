//
//  $Id$
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

#import <OpenGLES/ES1/gl.h>
#import "Texture2D.h"

@class TMFramedTexture, TMSprite;

@interface Quad : Texture2D {
}

- (id) initWithWidth:(NSUInteger)inWidth andHeight:(NSUInteger)inHeight;

// Drawing onto the quad
- (void) renderSprite:(TMSprite*)sprite atPoint:(CGPoint)point;
- (void) copyFrame:(int)frameId toPoint:(CGPoint)inPoint fromTexture:(TMFramedTexture*)texture;
- (void) copyFrame:(int)frameId withExtraLeft:(float)pixelsLeft extraRight:(float)pixelsRight 
		   toPoint:(CGPoint)inPoint fromTexture:(TMFramedTexture*)texture;

@end
