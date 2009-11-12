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

#import <OpenGLES/ES1/gl.h>

@class Texture2D, TMFramedTexture;

@interface Quad : NSObject {
	NSUInteger					m_unWidth, m_unHeight;
	CGSize						m_oSize;
	float						m_fMaxS, m_fMaxT;
	GLuint						m_unName;
}

@property(readonly) NSUInteger pixelsWide;
@property(readonly) NSUInteger pixelsHigh;

@property(readonly, nonatomic) CGSize contentSize;

- (id) initWithWidth:(NSUInteger)inWidth andHeight:(NSUInteger)inHeight;

// Drawing onto the quad
- (void) copyTextureSize:(CGSize)inSize toPoint:(CGPoint)inPoint fromTexture:(Texture2D*)texture;
- (void) copyFrame:(int)frameId toPoint:(CGPoint)inPoint fromTexture:(TMFramedTexture*)texture;

// Drawing the quad to the screen
- (void) drawInRect:(CGRect)inRect;
- (void) drawInRect:(CGRect)inRect rotation:(float)inRotation;
- (void) drawAtPoint:(CGPoint)point;

@end
