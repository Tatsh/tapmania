//
//  ZoomEffect.m
//  TapMania
//
//  Created by Alex Kremer on 17.02.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "ZoomEffect.h"
#import "TapMania.h"
#import "EAGLView.h"

@implementation ZoomEffect

- (id) initWithRenderable:(id)renderable {
	self = [super initWithRenderable:renderable];
	if(!self)
		return nil;
	
	m_fCurrentValue = 0.0f;
	m_nState = kZoomNone;
	
	return self;
}

/* TMLogicUpdater stuff */
- (void) update:(NSNumber*)fDelta {
		
	if(m_nState == kZoomIn) {

		m_fCurrentValue += kZoomStep;
		
		if(m_fCurrentValue >= kMaxZoomLevel) {
			m_fCurrentValue = kMaxZoomLevel;
			m_nState = kZoomNone;
		}
		
	} else if(m_nState == kZoomOut) {		
		m_fCurrentValue -= kZoomStep;
		
		if(m_fCurrentValue <= 0.0f) {
			m_fCurrentValue = 0.0f;
			m_nState = kZoomNone;			
		}
	}
	
	if(m_nState != kZoomNone) {
		CGRect newShape = CGRectMake(m_rOriginalShape.origin.x-m_fCurrentValue, m_rOriginalShape.origin.y-m_fCurrentValue, 
									 m_rOriginalShape.size.width+(m_fCurrentValue*2), m_rOriginalShape.size.height+(m_fCurrentValue*2));
		
		[self updateShape:newShape];	// Update internal shape of our effect
	}
	
	[super update:fDelta];
}

/* TMGameUIResponder stuff */
- (void) tmTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {	
	UITouch * touch = [touches anyObject];
	CGPoint point = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:
					 [touch locationInView:[TapMania sharedInstance].glView]];
	
	if(CGRectContainsPoint(m_rShape, point)) {
		m_nState = kZoomIn;
	}
	
	[m_idDecoratedObject tmTouchesBegan:touches withEvent:event];
}

- (void) tmTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {	
	UITouch * touch = [touches anyObject];
	CGPoint point = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:
					 [touch locationInView:[TapMania sharedInstance].glView]];
	
	if(CGRectContainsPoint(m_rShape, point)) {
		m_nState = kZoomIn;
	} else {
		m_nState = kZoomOut;
	}

	[m_idDecoratedObject tmTouchesMoved:touches withEvent:event];
}

- (void) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {		
	UITouch * touch = [touches anyObject];
	CGPoint point = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:
					 [touch locationInView:[TapMania sharedInstance].glView]];
	
	if(CGRectContainsPoint(m_rShape, point)) {
		m_nState = kZoomOut;
	}
	
	[m_idDecoratedObject tmTouchesEnded:touches withEvent:event];
}

@end
