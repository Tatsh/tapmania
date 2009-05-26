//
//  ImageButton.m
//  TapMania
//
//  Created by Alex Kremer on 5/27/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "ImageButton.h"
#import "TMFramedTexture.h"
#import "ThemeManager.h"
#import "Texture2D.h"
#import "TapMania.h"
#import "EAGLView.h"

@implementation ImageButton

- (id) initWithTexture:(Texture2D*) tex andShape:(CGRect) shape {
	self = [super init];
	if(!self) 
		return nil;
	
	m_rShape = shape;
	m_pTexture = tex;
	
	m_idActionDelegate = nil;
	m_oActionHandler = nil;
	m_oChangedActionHandler = nil;
	
	return self;
}

- (BOOL) containsPoint:(CGPoint)point {
	return CGRectContainsPoint(m_rShape, point);
}

- (void) setActionHandler:(SEL)selector receiver:(id)receiver {
	m_idActionDelegate = receiver;
	m_oActionHandler = selector;
}

- (void) setChangedActionHandler:(SEL)selector receiver:(id)receiver {
	m_idChangedDelegate = receiver;
	m_oChangedActionHandler = selector;
}

/* TMRenderable stuff */
- (void) render:(float)fDelta {
	glEnable(GL_BLEND);
	[m_pTexture drawInRect:m_rShape];
	glDisable(GL_BLEND);
}

/* TMGameUIResponder stuff */
- (void) tmTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {	
	if(m_idActionDelegate != nil && [m_idActionDelegate respondsToSelector:m_oActionHandler]) {
		UITouch * touch = [touches anyObject];
		CGPoint point = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:
						 [touch locationInView:[TapMania sharedInstance].glView]];
		
		if(CGRectContainsPoint(m_rShape, point)) {
			TMLog(@"Image button hit!");
		}
	}
}

- (void) tmTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {	
	if(m_idChangedDelegate != nil && [m_idChangedDelegate respondsToSelector:m_oChangedActionHandler]) {
		UITouch * touch = [touches anyObject];
		CGPoint point = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:
						 [touch locationInView:[TapMania sharedInstance].glView]];
		
		if(CGRectContainsPoint(m_rShape, point)) {
			[m_idChangedDelegate performSelector:m_oChangedActionHandler];
		}
	}
}

- (void) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {	
	if(m_idActionDelegate != nil && [m_idActionDelegate respondsToSelector:m_oActionHandler]) {
		UITouch * touch = [touches anyObject];
		CGPoint point = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:
						 [touch locationInView:[TapMania sharedInstance].glView]];
		
		if(CGRectContainsPoint(m_rShape, point)) {
			TMLog(@"Image button finger raised!");
			[m_idActionDelegate performSelector:m_oActionHandler];
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
