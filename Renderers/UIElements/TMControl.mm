//
//  TMControl.m
//  TapMania
//
//  Created by Alex Kremer on 16.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMControl.h"
#import "TapMania.h"
#import "ThemeManager.h"
#import "CommandParser.h"
#import "EAGLView.h"

@implementation TMControl

- (id) initWithMetrics:(NSString*)inMetricsKey {
	self = [self initWithShape:RECT_METRIC(inMetricsKey)];
	if(!self)
		return nil;
	
	// Try to get the command list
	NSString* commandList = STR_METRIC([inMetricsKey stringByAppendingString:@" OnCommand"]);
	if([commandList length] > 0) {
		m_pCommandList = [[[CommandParser sharedInstance] createCommandListFromString:commandList forRequestingObject:self] retain];
	}
	
	return self;
}

- (id) initWithShape:(CGRect)inShape {
	self = [super initWithShape:inShape];
	if(!self) 
		return nil;
	
	m_pCommandList = nil;
	m_idActionDelegate = nil;
	m_idChangedDelegate = nil;
	m_oActionHandler = nil;
	m_oChangedActionHandler = nil;
	
	return self;
}

- (void) dealloc {
	if(m_pCommandList)
		[m_pCommandList release];
	[super dealloc];
}

- (void) setActionHandler:(SEL)selector receiver:(id)receiver {
	m_idActionDelegate = receiver;
	m_oActionHandler = selector;
}

- (void) setChangedActionHandler:(SEL)selector receiver:(id)receiver {
	m_idChangedDelegate = receiver;
	m_oChangedActionHandler = selector;
}

- (void) setCommandList:(NSArray*)inCmdList {
	m_pCommandList = inCmdList;
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
	BOOL res = NO;
	
	if(m_pCommandList != nil) {
		if([super tmTouchesEnded:touches withEvent:event]) {
			TMLog(@"Running control's OnCommand...");
			[[CommandParser sharedInstance] runCommandList:m_pCommandList forRequestingObject:self];
			res = YES;
		}
	}
	
	if(m_idActionDelegate != nil && [m_idActionDelegate respondsToSelector:m_oActionHandler]) {
		if([super tmTouchesEnded:touches withEvent:event]) {
			TMLog(@"Control, finger raised!");
			[m_idActionDelegate performSelector:m_oActionHandler];

			res = YES;
		}
	}
	
	return res;
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
