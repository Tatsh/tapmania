//
//  MenuItem.m
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "MenuItem.h"
#import "TexturesHolder.h"


@implementation MenuItem
 
- (id) initWithTexture:(int) textureId andShape:(CGRect) shape {
	self = [super init];
	if(!self) 
		return nil;
	
	m_rShape = shape;
	m_nTextureId = textureId;
	
	return self;
}

- (BOOL) containsPoint:(CGPoint)point {
	return CGRectContainsPoint(m_rShape, point);
}


/* TMRenderable stuff */
- (void) render:(NSNumber*)fDelta {
	[[[TexturesHolder sharedInstance] getTexture:m_nTextureId] drawInRect:m_rShape];
}

@end
