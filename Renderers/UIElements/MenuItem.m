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
 
- (id) initWithTexture:(int) lTextureId andShape:(CGRect) lShape {
	self = [super init];
	if(!self) 
		return nil;
	
	shape = lShape;
	textureId = lTextureId;
	
	return self;
}

- (BOOL) containsPoint:(CGPoint)point {
	return CGRectContainsPoint(shape, point);
}


/* TMRenderable stuff */
- (void) render:(NSNumber*)fDelta {
	[[[TexturesHolder sharedInstance] getTexture:textureId] drawInRect:shape];
}

@end
