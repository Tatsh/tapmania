//
//  MenuItem.m
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "MenuItem.h"
#import "Texture2D.h"

@implementation MenuItem
 
- (id) initWithTexture:(Texture2D*) texture andShape:(CGRect) shape {
	self = [super init];
	if(!self) 
		return nil;
	
	m_rShape = shape;
	m_pTexture = texture;
	
	return self;
}

- (BOOL) containsPoint:(CGPoint)point {
	return CGRectContainsPoint(m_rShape, point);
}

- (CGPoint) getPosition {
	return m_rShape.origin;
}

- (void) updatePosition:(CGPoint)point {
	m_rShape.origin.x = point.x;
	m_rShape.origin.y = point.y;
}

/* TMRenderable stuff */
- (void) render:(NSNumber*)fDelta {
	glEnable(GL_BLEND);
	[m_pTexture drawInRect:m_rShape];
	glDisable(GL_BLEND);

}

@end
