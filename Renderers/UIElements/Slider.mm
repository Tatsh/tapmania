//
//  Slider.m
//  TapMania
//
//  Created by Alex Kremer on 23.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TapMania.h"
#import "EAGLView.h"
#import "Slider.h"

#import "CommandParser.h"
#import "ThemeManager.h"
#import "TMFramedTexture.h"

@interface Slider (Private)
- (void) setValueFromPoint:(CGPoint)point;
@end


@implementation Slider

- (id) initWithShape:(CGRect)shape andValue:(float)xValue {	
	self = [super initWithShape:shape];
	if(!self)
		return nil;
	
	// limit the value to 0.0-1.0 range
	m_fCurrentValue = fminf(1.0f, fmaxf(xValue, 0.0f));
	m_pTexture = (TMFramedTexture*)[[ThemeManager sharedInstance] texture:@"Common Slider"];	
	
	return self;
}

- (id) initWithMetrics:(NSString*)inMetricsKey {
	self = [super initWithShape:RECT_METRIC(inMetricsKey)];
	if(!self) 
		return nil;
	
	m_pTexture = (TMFramedTexture*)[[ThemeManager sharedInstance] texture:@"Common Slider"];	
	m_fCurrentValue = 0.0f;
	
	// Add commands support
	// Try to get the command list. can be omitted
	NSString* commandList = STR_METRIC([inMetricsKey stringByAppendingString:@" OnCommand"]);
	if(commandList && [commandList length] > 0) {
		m_pCommandList = [[[CommandParser sharedInstance] createCommandListFromString:commandList forRequestingObject:self] retain];
	}

	NSString* slideCommandList = STR_METRIC([inMetricsKey stringByAppendingString:@" OnSlideCommand"]);
	if(slideCommandList && [slideCommandList length] > 0) {
		m_pSlideCommandList = [[[CommandParser sharedInstance] createCommandListFromString:slideCommandList forRequestingObject:self] retain];
	}
	
	return self;
}	

- (void) dealloc {
	if(m_pSlideCommandList) [m_pSlideCommandList release];
	[super dealloc];
}

- (void) setValueFromPoint:(CGPoint)point {
	float dist = point.x - m_rShape.origin.x;

	if(dist <= 0.01f) {
		m_fCurrentValue = 0.0f;
	} else {
		m_fCurrentValue = dist / m_rShape.size.width;

		if(m_fCurrentValue >= 0.99)
			m_fCurrentValue = 1.0f;
	}
}

- (NSNumber*) currentValue {
	return [NSNumber numberWithFloat:m_fCurrentValue];
}

- (void) setValue:(NSObject*)value {
	// limit the value to 0.0-1.0 range
	m_fCurrentValue = fminf(1.0f, fmaxf([(NSNumber*)value floatValue], 0.0f));
}

/* TMRenderable stuff */
- (void) render:(float)fDelta {
	CGRect leftCapRect = CGRectMake(m_rShape.origin.x, m_rShape.origin.y, 46.0f, m_rShape.size.height);
	CGRect rightCapRect = CGRectMake(m_rShape.origin.x+m_rShape.size.width-46.0f, m_rShape.origin.y, 46.0f, m_rShape.size.height);
	CGRect bodyRect = CGRectMake(m_rShape.origin.x+46.0f, m_rShape.origin.y, m_rShape.size.width-92.0f, m_rShape.size.height); 
	
	float thumbOffset = m_fCurrentValue*m_rShape.size.width - 23.0f;	// minus half thumb width
	CGRect thumbRect = CGRectMake(m_rShape.origin.x+thumbOffset, m_rShape.origin.y, 46.0f, m_rShape.size.height);
	
	glEnable(GL_BLEND);
	[(TMFramedTexture*)m_pTexture drawFrame:0 inRect:leftCapRect];
	[(TMFramedTexture*)m_pTexture drawFrame:1 inRect:bodyRect];
	[(TMFramedTexture*)m_pTexture drawFrame:2 inRect:rightCapRect];
	[(TMFramedTexture*)m_pTexture drawFrame:3 inRect:thumbRect];	
	glDisable(GL_BLEND);
}

/* TMGameUIResponder method */
- (BOOL) tmTouchesMoved:(const TMTouchesVec&)touches withEvent:(UIEvent*)event {
	if(touches.size() == 1){
		TMTouch touch = touches.at(0);
			
		CGPoint point = CGPointMake(touch.x(), touch.y());
		
		if([self containsPoint:point]) {
			[self setValueFromPoint:point];
			
			if(m_pSlideCommandList) {
				TMLog(@"Running slider's OnSlideCommand...");
				[[CommandParser sharedInstance] runCommandList:m_pSlideCommandList forRequestingObject:self];	
			}
			
			[super tmTouchesMoved:touches withEvent:event];						
			return YES;
		}
	}
	
	return NO;
}

- (BOOL) tmTouchesEnded:(const TMTouchesVec&)touches withEvent:(UIEvent*)event {
	if([self tmTouchesMoved:touches withEvent:event]) {
		[super tmTouchesEnded:touches withEvent:event];
		
		return YES;
	}
	
	return NO;
}


@end
