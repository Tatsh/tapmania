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
	self = [super initWithShape:inShape];
	if(!self) 
		return nil;
	
	m_idActionDelegate = nil;
	m_idChangedDelegate = nil;
	m_oActionHandler = nil;
	m_oChangedActionHandler = nil;
	
	return self;
}

- (void) setActionHandler:(SEL)selector receiver:(id)receiver {
	m_idActionDelegate = receiver;
	m_oActionHandler = selector;
}

- (void) setChangedActionHandler:(SEL)selector receiver:(id)receiver {
	m_idChangedDelegate = receiver;
	m_oChangedActionHandler = selector;
}

/* TMGameUIResponder stuff */
- (BOOL) tmTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {	
	if(m_idActionDelegate != nil && [m_idActionDelegate respondsToSelector:m_oActionHandler]) {
		if([super tmTouchesBegan:touches withEvent:event]) {
			TMLog(@"Control touched");
			
			return YES;
		}
	}
	
	return NO;
}

- (BOOL) tmTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {	
	if(m_idChangedDelegate != nil && [m_idChangedDelegate respondsToSelector:m_oChangedActionHandler]) {
		if([super tmTouchesMoved:touches withEvent:event]) {
			TMLog(@"Control touches moved");
			[m_idChangedDelegate performSelector:m_oChangedActionHandler];			
			
			return YES;
		}
	}
	
	return NO;
}

- (BOOL) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {	
	if(m_idActionDelegate != nil && [m_idActionDelegate respondsToSelector:m_oActionHandler]) {
		if([super tmTouchesEnded:touches withEvent:event]) {
			TMLog(@"Control, finger raised!");
			[m_idActionDelegate performSelector:m_oActionHandler];

			return YES;
		}
	}
	
	return NO;
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
