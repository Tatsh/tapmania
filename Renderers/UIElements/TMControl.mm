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
	
	[self initCommands:inMetricsKey];
	
	return self;
}

- (id) initWithShape:(CGRect)inShape {
	self = [super initWithShape:inShape];
	if(!self) 
		return nil;
	
	m_pOnCommand = m_pOffCommand = m_pSlideCommand = nil;
	m_idActionDelegate = nil;
	m_idChangedDelegate = nil;
	m_oActionHandler = nil;
	m_oChangedActionHandler = nil;
	
	return self;
}

- (void) initCommands:(NSString*)inMetricsKey {
	// Try to get the commands. can be omitted
	NSString* onCommandList = STR_METRIC([inMetricsKey stringByAppendingString:@" OnCommand"]);
	if([onCommandList length] > 0) {
		m_pOnCommand = [[[CommandParser sharedInstance] createCommandListFromString:onCommandList forRequestingObject:self] retain];
	}
	
	NSString* offCommandList = STR_METRIC([inMetricsKey stringByAppendingString:@" OffCommand"]);
	if([offCommandList length] > 0) {
		m_pOffCommand = [[[CommandParser sharedInstance] createCommandListFromString:offCommandList forRequestingObject:self] retain];
	}
	
	NSString* slideCommandList = STR_METRIC([inMetricsKey stringByAppendingString:@" SlideCommand"]);
	if([slideCommandList length] > 0) {
		m_pSlideCommand = [[[CommandParser sharedInstance] createCommandListFromString:slideCommandList forRequestingObject:self] retain];
	}	
}

- (void) initGraphicsAndSounds:(NSString*)inMetricsKey {
	// Override this
}

- (void) dealloc {
	if(m_pOnCommand)
		[m_pOnCommand release];
	if(m_pOffCommand)
		[m_pOffCommand release];
	if(m_pSlideCommand)
		[m_pSlideCommand release];
	
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

- (void) setOnCommand:(TMCommand*)inCmd {
	m_pOnCommand = inCmd;
}

- (void) setOffCommand:(TMCommand*)inCmd {
	m_pOffCommand = inCmd;
}

- (void) setSlideCommand:(TMCommand*)inCmd {
	m_pSlideCommand = inCmd;
}

/* TMGameUIResponder stuff */
- (BOOL) tmTouchesBegan:(const TMTouchesVec&)touches withEvent:(UIEvent*)event {	
	BOOL res = NO;
	
	if(m_pOnCommand != nil) {
		if([super tmTouchesBegan:touches withEvent:event]) {
			TMLog(@"Running control's OnCommand...");
			[[CommandParser sharedInstance] runCommandList:m_pOnCommand forRequestingObject:self];
			res = YES;
		}
	}	
	
	if(m_idActionDelegate != nil && [m_idActionDelegate respondsToSelector:m_oActionHandler]) {
		if([super tmTouchesBegan:touches withEvent:event]) {
			TMLog(@"Control touched");
			
			res = YES;
		}
	}
	
	return res;
}

- (BOOL) tmTouchesMoved:(const TMTouchesVec&)touches withEvent:(UIEvent*)event {	
	BOOL res = NO;
	
	if(m_pSlideCommand != nil) {
		if([super tmTouchesMoved:touches withEvent:event]) {
			TMLog(@"Running control's SlideCommand...");
			[[CommandParser sharedInstance] runCommandList:m_pSlideCommand forRequestingObject:self];
			res = YES;
		}
	}	
	
	if(m_idChangedDelegate != nil && [m_idChangedDelegate respondsToSelector:m_oChangedActionHandler]) {
		if([super tmTouchesMoved:touches withEvent:event]) {
			TMLog(@"Control touches moved");
			[m_idChangedDelegate performSelector:m_oChangedActionHandler];			
			
			res = YES;
		}
	}
	
	return res;
}

- (BOOL) tmTouchesEnded:(const TMTouchesVec&)touches withEvent:(UIEvent*)event {	
	BOOL res = NO;
	
	if(m_pOffCommand != nil) {
		if([super tmTouchesEnded:touches withEvent:event]) {
			TMLog(@"Running control's OffCommand...");
			[[CommandParser sharedInstance] runCommandList:m_pOffCommand forRequestingObject:self];
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
