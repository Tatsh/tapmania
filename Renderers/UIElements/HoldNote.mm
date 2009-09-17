//
//  HoldNote.m
//  TapMania
//
//  Created by Alex Kremer on 10.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "HoldNote.h"


@implementation HoldNote

- (void) drawBodyPieceWithSize:(CGFloat)size atPoint:(CGPoint)point {
	// Size is the size in pixels to crop the texture from the bottom of it
	
	float minTextureFromSize = m_fMaxT - (m_fMaxT * (size / m_unHeight));
	
	GLfloat		coordinates[] = { 
		0,		m_fMaxT,
		m_fMaxS,	m_fMaxT,
		0,		minTextureFromSize,
		m_fMaxS,	minTextureFromSize 
	};
	
	GLfloat		width = (GLfloat)m_unWidth * m_fMaxS,
				height = size;

	GLfloat		vertices[] = {	
		point.x,		point.y,		0.0,
		point.x+width,	point.y,		0.0,
		point.x,		point.y+height,	0.0,
		point.x+width,	point.y+height,	0.0 
	};
	
	glEnable(GL_BLEND);
	glBindTexture(GL_TEXTURE_2D, m_unName);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);	
	glDisable(GL_BLEND);
}

@end
