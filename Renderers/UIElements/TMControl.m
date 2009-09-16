//
//  TMControl.m
//  TapMania
//
//  Created by Alex Kremer on 16.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMControl.h"
#import "TapMania.h"
#import "EAGLView.h"

@implementation TMControl

- (id) initWithShape:(CGRect)inShape {
	self = [super init];
	if(!self) 
		return nil;
	
	m_rShape = inShape;
	
	m_idActionDelegate = nil;
	m_idChangedDelegate = nil;
	m_oActionHandler = nil;
	m_oChangedActionHandler = nil;
	
	m_bVisible = YES;
	m_bEnabled = YES;
	
	return self;
}

- (void) show {
	m_bVisible = YES;
}

- (void) hide {
	m_bVisible = NO;
}

- (void) disable {
	m_bEnabled = NO;
}

- (void) enable {
	m_bEnabled = YES;
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
}

/* TMLogicUpdater stuff */
- (void) update:(float)fDelta {
}

/* TMGameUIResponder stuff */
- (void) tmTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {	
	if(m_idActionDelegate != nil && [m_idActionDelegate respondsToSelector:m_oActionHandler]) {
		UITouch * touch = [touches anyObject];
		CGPoint point = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:
						 [touch locationInView:[TapMania sharedInstance].glView]];
		
		if(CGRectContainsPoint(m_rShape, point)) {
			if(m_bEnabled && m_bVisible) {
				TMLog(@"Control, start touching.");
			}
		}
	}
}

- (void) tmTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {	
	if(m_idChangedDelegate != nil && [m_idChangedDelegate respondsToSelector:m_oChangedActionHandler]) {
		UITouch * touch = [touches anyObject];
		CGPoint point = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:
						 [touch locationInView:[TapMania sharedInstance].glView]];
		
		if(CGRectContainsPoint(m_rShape, point)) {
			if(m_bEnabled && m_bVisible && m_idChangedDelegate != nil) {
				[m_idChangedDelegate performSelector:m_oChangedActionHandler];
			}
		}
	}
}

- (void) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {	
	if(m_idActionDelegate != nil && [m_idActionDelegate respondsToSelector:m_oActionHandler]) {
		UITouch * touch = [touches anyObject];
		CGPoint point = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:
						 [touch locationInView:[TapMania sharedInstance].glView]];
		
		if(CGRectContainsPoint(m_rShape, point)) {
			if(m_bEnabled && m_bVisible && m_idActionDelegate != nil) {
				TMLog(@"Control, finger raised!");
				[m_idActionDelegate performSelector:m_oActionHandler];
			}
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
