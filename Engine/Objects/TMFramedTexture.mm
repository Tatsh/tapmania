//
//  $Id$
//  TMFramedTexture.m
//  TapMania
//
//  Created by Alex Kremer on 04.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMFramedTexture.h"
#include "GLUtil.h"


@implementation TMFramedTexture
	
@synthesize m_nTotalFrames;

- (id) initWithImage:(UIImage *)uiImage columns:(int)columns andRows:(int)rows {
	self = [super initWithImage:uiImage];
	if(!self) 
		return nil;
	
	m_nFramesToLoad[0] = columns;
	m_nFramesToLoad[1] = rows;
	m_nTotalFrames = columns*rows;
	
	return self;
}

- (int) cols {
	return m_nFramesToLoad[0];
}

- (int) rows {
	return m_nFramesToLoad[1];
}

- (void) drawFrame:(int)frameId rotation:(float)rotation inRect:(CGRect)rect {
	glPushMatrix();
	
	glTranslatef(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2, 0.0);
	glRotatef(rotation, 0, 0, 1);
	
	// Sanity check
	if(frameId >= m_nTotalFrames || frameId < 0)
		frameId = 0;
	
	float textureMaxT = m_fMaxT/m_nFramesToLoad[1];
	float textureMaxS = m_fMaxS/m_nFramesToLoad[0];
	
	int textureRow = frameId/m_nFramesToLoad[0];
	frameId -= textureRow*m_nFramesToLoad[0];
	
	float yOffset = textureRow*textureMaxT;
	float xOffset = frameId*textureMaxS;
	float widthOffset = xOffset + textureMaxS;
	float heightOffset = yOffset + textureMaxT;
	
	float width = rect.size.width;	
	float height = rect.size.height;
	
	GLfloat	 coordinates[] = {  
		xOffset,		heightOffset,
		widthOffset,	heightOffset,
		xOffset,		yOffset,
		widthOffset,	yOffset  
	};	
	
	GLfloat		vertices[] = {	
		-width / 2,	-height / 2,	0.0,
		width / 2,	-height / 2,	0.0,
		-width / 2,	height / 2,	0.0,
		width / 2,	height / 2,	0.0 
	};
	
	TMBindTexture(m_unName);
    glEnable(GL_BLEND);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisable(GL_BLEND);
    
	glPopMatrix();
}

- (void) drawFrame:(int)frameId atPoint:(CGPoint)point withScale:(float)scale {
	// Sanity check
	if(frameId >= m_nTotalFrames || frameId < 0)
		frameId = 0;
	
	float textureMaxT = m_fMaxT/m_nFramesToLoad[1];
	float textureMaxS = m_fMaxS/m_nFramesToLoad[0];
	
	int textureRow = frameId/m_nFramesToLoad[0];
	frameId -= textureRow*m_nFramesToLoad[0];
	
	float yOffset = textureRow*textureMaxT;
	float xOffset = frameId*textureMaxS;
	float widthOffset = xOffset + textureMaxS;
	float heightOffset = yOffset + textureMaxT;
	
	float width = m_oSize.width/m_nFramesToLoad[0] * scale;
	float height = m_oSize.height/m_nFramesToLoad[1] * scale;
	
	GLfloat	 coordinates[] = {  
		xOffset,		heightOffset,
		widthOffset,	heightOffset,
		xOffset,		yOffset,
		widthOffset,	yOffset  
	};	
	
	GLfloat		vertices[] = {	
		-width / 2 + point.x,	-height / 2 + point.y,	0.0,
		width / 2 + point.x,	-height / 2 + point.y,	0.0,
		-width / 2 + point.x,	height / 2 + point.y,	0.0,
		width / 2 + point.x,	height / 2 + point.y,	0.0 
	};
	
	TMBindTexture(m_unName);
    glEnable(GL_BLEND);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisable(GL_BLEND);
}

- (void) drawFrame:(int)frameId {
	[self drawFrame:frameId atPoint:CGPointZero];
}
- (void) drawFrame:(int)frameId atPoint:(CGPoint)point {
	[self drawFrame:frameId withExtraLeft:0.0f extraRight:0.0f atPoint:point];
}

- (void) drawFrame:(int)frameId withExtraLeft:(float)pixelsLeft extraRight:(float)pixelsRight atPoint:(CGPoint)point {
	// Sanity check
	if(frameId >= m_nTotalFrames || frameId < 0)
	frameId = 0;

	float textureMaxT = m_fMaxT/m_nFramesToLoad[1];
	float textureMaxS = m_fMaxS/m_nFramesToLoad[0];

	int textureRow = frameId/m_nFramesToLoad[0];
	frameId -= textureRow*m_nFramesToLoad[0];

	pixelsLeft *= m_fMaxS;
	pixelsRight *= m_fMaxS;
	
	float yOffset = textureRow*textureMaxT;
	float xOffset = frameId*textureMaxS;
	
	float widthOffset = xOffset + textureMaxS - pixelsRight;
	xOffset -= pixelsLeft;
	float heightOffset = yOffset + textureMaxT;
	
	float width = m_oSize.width/m_nFramesToLoad[0];
	float height = m_oSize.height/m_nFramesToLoad[1];

	GLfloat	 coordinates[] = {  
		xOffset,		heightOffset,
		widthOffset,	heightOffset,
		xOffset,		yOffset,
		widthOffset,	yOffset  
	};	

	GLfloat		vertices[] = {	
		-width / 2 + point.x,	-height / 2 + point.y,	0.0,
		width / 2 + point.x,	-height / 2 + point.y,	0.0,
		-width / 2 + point.x,	height / 2 + point.y,	0.0,
		width / 2 + point.x,	height / 2 + point.y,	0.0 
	};

    glEnable(GL_BLEND);
	TMBindTexture(m_unName);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisable(GL_BLEND);
}

- (void) drawFrame:(int)frameId withExtraLeft:(float)pixelsLeft extraRight:(float)pixelsRight inRect:(CGRect)rect {
	// Sanity check
	if(frameId >= m_nTotalFrames || frameId < 0)
		frameId = 0;
	
	float textureMaxT = m_fMaxT/m_nFramesToLoad[1];
	float textureMaxS = m_fMaxS/m_nFramesToLoad[0];
	
	int textureRow = frameId/m_nFramesToLoad[0];
	frameId -= textureRow*m_nFramesToLoad[0];
	
	pixelsLeft *= m_fMaxS;
	pixelsRight *= m_fMaxS;
	
	float yOffset = textureRow*textureMaxT;
	float xOffset = frameId*textureMaxS;
	
	float widthOffset = xOffset + textureMaxS - pixelsRight;
	xOffset -= pixelsLeft;
	float heightOffset = yOffset + textureMaxT;
		
	GLfloat	 coordinates[] = {  
		xOffset,		heightOffset,
		widthOffset,	heightOffset,
		xOffset,		yOffset,
		widthOffset,	yOffset  
	};
	
	GLfloat	vertices[] = {
		rect.origin.x,							rect.origin.y,							0.0,
		rect.origin.x + rect.size.width,		rect.origin.y,							0.0,
		rect.origin.x,							rect.origin.y + rect.size.height,		0.0,
		rect.origin.x + rect.size.width,		rect.origin.y + rect.size.height,		0.0 
	};
	
    glEnable(GL_BLEND);
	TMBindTexture(m_unName);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisable(GL_BLEND);
}

- (void) drawFrame:(int)frameId inRect:(CGRect)rect {
	[self drawFrame:frameId withExtraLeft:0.0f extraRight:0.0f inRect:rect];
}

@end
