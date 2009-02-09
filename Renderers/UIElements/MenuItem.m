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


/* TMRenderable stuff */
- (void) render:(NSNumber*)fDelta {
	[m_pTexture drawInRect:m_rShape];
}

@end
