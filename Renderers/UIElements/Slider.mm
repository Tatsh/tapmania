//
//  $Id$
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

#import "DisplayUtil.h"

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
	
	[self initGraphicsAndSounds:@"Common Slider"];
	
	return self;
}

- (id) initWithMetrics:(NSString*)inMetricsKey {
	self = [super initWithShape:RECT_METRIC(inMetricsKey)];
	if(!self) 
		return nil;
	
	[self initGraphicsAndSounds:inMetricsKey];
	m_fCurrentValue = 0.0f;
	
	// Add commands support
	[super initCommands:inMetricsKey];
	
	return self;
}	

- (void) initGraphicsAndSounds:(NSString*)inMetricsKey {
	[super initGraphicsAndSounds:inMetricsKey];
	NSString* inFb = @"Common Slider";
	
	// Load texture
	m_pTexture = (TMFramedTexture*)[[ThemeManager sharedInstance] texture:inMetricsKey];
	if(!m_pTexture) {
		m_pTexture = (TMFramedTexture*)[[ThemeManager sharedInstance] texture:inFb];		
	}
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
    float capWidth = 46.0f;
    if([DisplayUtil isRetina])
    {
        capWidth *= 2.0f;
    }
    
	CGRect leftCapRect = CGRectMake(m_rShape.origin.x, m_rShape.origin.y, capWidth, m_rShape.size.height);
	CGRect rightCapRect = CGRectMake(m_rShape.origin.x+m_rShape.size.width-capWidth, m_rShape.origin.y, capWidth, m_rShape.size.height);
	CGRect bodyRect = CGRectMake(m_rShape.origin.x+capWidth, m_rShape.origin.y, m_rShape.size.width-(capWidth*2.0f), m_rShape.size.height);
	
	float thumbOffset = m_fCurrentValue*m_rShape.size.width - (capWidth/2.0f);	// minus half thumb width
	CGRect thumbRect = CGRectMake(m_rShape.origin.x+thumbOffset, m_rShape.origin.y, capWidth, m_rShape.size.height);
	
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

		// Set the current value of the slider (0.0-1.0)
		if([self containsPoint:point]) {
			[self setValueFromPoint:point];			
		}

		// Run commands etc.
		[super tmTouchesMoved:touches withEvent:event];								
		return YES;
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
