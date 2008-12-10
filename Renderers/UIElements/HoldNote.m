//
//  HoldNote.m
//  TapMania
//
//  Created by Alex Kremer on 10.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "HoldNote.h"


@implementation HoldNote

- (void) drawBodyPieceWithSize:(CGFloat)lSize atPoint:(CGPoint)point {
	// Size is the size in pixels to crop the texture from the bottom of it
	
	float minTextureFromSize = _maxT - (_maxT * (lSize / _height));
	
	GLfloat		coordinates[] = { 
		0,		_maxT,
		_maxS,	_maxT,
		0,		minTextureFromSize,
		_maxS,	minTextureFromSize 
	};
	
	GLfloat		width = (GLfloat)_width * _maxS,
				height = lSize;

	GLfloat		vertices[] = {	
		point.x,		point.y,		0.0,
		point.x+width,	point.y,		0.0,
		point.x,		point.y+height,	0.0,
		point.x+width,	point.y+height,	0.0 
	};
	
	glBindTexture(GL_TEXTURE_2D, _name);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);	
}

@end
