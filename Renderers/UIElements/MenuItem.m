//
//  MenuItem.m
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "MenuItem.h"
#import "Texture2D.h"
#import "TapMania.h"
#import "EAGLView.h"

@implementation MenuItem

- (id) initWithTexture:(Texture2D*) texture andShape:(CGRect) shape {
	self = [super init];
	if(!self) 
		return nil;
	
	m_rShape = shape;
	m_pTexture = texture;
	
	m_idDelegate = nil;
	m_oActionHandler = nil;
	
	return self;
}

- (BOOL) containsPoint:(CGPoint)point {
	return CGRectContainsPoint(m_rShape, point);
}

- (void) setActionHandler:(SEL)selector receiver:(id)receiver {
	m_idDelegate = receiver;
	m_oActionHandler = selector;
}

/* TMRenderable stuff */
- (void) render:(NSNumber*)fDelta {
	glEnable(GL_BLEND);
	[m_pTexture drawInRect:m_rShape];
	glDisable(GL_BLEND);
}

/* TMGameUIResponder stuff */
- (void) tmTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {	
	if(m_idDelegate != nil && [m_idDelegate respondsToSelector:m_oActionHandler]) {
		UITouch * touch = [touches anyObject];
		CGPoint point = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:
							[touch locationInView:[TapMania sharedInstance].glView]];

		if(CGRectContainsPoint(m_rShape, point)) {
			TMLog(@"Menu item hit!");
		}
	}
}

- (void) tmTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {	
	if(m_idDelegate != nil && [m_idDelegate respondsToSelector:m_oActionHandler]) {
		UITouch * touch = [touches anyObject];
		CGPoint point = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:
						 [touch locationInView:[TapMania sharedInstance].glView]];
		
		if(CGRectContainsPoint(m_rShape, point)) {
			TMLog(@"Menu item finger moved!");
		}
	}
}

- (void) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {	
	if(m_idDelegate != nil && [m_idDelegate respondsToSelector:m_oActionHandler]) {
		UITouch * touch = [touches anyObject];
		CGPoint point = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:
						 [touch locationInView:[TapMania sharedInstance].glView]];
		
		if(CGRectContainsPoint(m_rShape, point)) {
			TMLog(@"Menu item finger raised!");
			[m_idDelegate performSelector:m_oActionHandler];
		}
	}
}

/* TMEffectSupport stuff */
- (CGPoint) getPosition {
	return m_rShape.origin;
}

- (void) updatePosition:(CGPoint)point {
	m_rShape.origin.x = point.x;
	m_rShape.origin.y = point.y;
}

- (CGRect) getShape {
	return m_rShape;
}

- (void) updateShape:(CGRect)shape {
	m_rShape.origin = shape.origin;
	m_rShape.size = shape.size;
}

@end
