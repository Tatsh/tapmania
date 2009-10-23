//
//  TMView.m
//  TapMania
//
//  Created by Alex Kremer on 17.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMView.h"
#import "TapMania.h"
#import "EAGLView.h"
#import "InputEngine.h"

@implementation TMView

- (id) initWithShape:(CGRect)inShape {
	self = [super init];
	if(!self) 
		return nil;
	
	m_rShape = inShape;	
	m_bVisible = YES;
	m_bEnabled = YES;
	
	m_pChildren = new TMViewChildren();
	m_pControls = new TMViewChildren();
	
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

-(void) pushBackChild:(TMView*)inChild {
	m_pChildren->push_back( TMViewChildPtr( inChild ) );	
}

-(void) pushChild:(TMView*)inChild {
	m_pChildren->push_front( TMViewChildPtr( inChild ) );	
}

-(void) pushBackControl:(TMControl*)inChild {
	TMViewChildPtr ptr = TMViewChildPtr( reinterpret_cast<TMView*>(inChild) );
	m_pChildren->push_back( ptr );	
	m_pControls->push_back( ptr );
}

-(TMView*) popBackChild {
	if(m_pChildren->empty())
		return nil;
	
	TMViewChildPtr objPtr = m_pChildren->back();
	m_pChildren->pop_back();
	
	return reinterpret_cast<TMView*> (*objPtr);
}

-(TMView*) popChild {
	if(m_pChildren->empty())
		return nil;
	
	TMViewChildPtr objPtr = m_pChildren->front();
	m_pChildren->pop_front();
	
	return reinterpret_cast<TMView*> (*objPtr);
}

- (void) dealloc {
	TMLog(@"Deallocating TMView instance.. %@", self);
	delete m_pControls;
	delete m_pChildren;
	
	[super dealloc];
}

/* TMRenderable method */
- (void) render:(float)fDelta {
	int curSize = m_pChildren->size();
	
	/* Now draw all children */
	for (int i = 0; i < curSize; ++i) {				
		TMViewChildPtr& obj = m_pChildren->at(i);
		
		[(id<TMRenderable>)*obj render:fDelta];
		
		// To be safe we must update the curSize everytime
		curSize = m_pChildren->size();
	}
}

/* TMLogicUpdater stuff */
- (void) update:(float)fDelta {
	int curSize = m_pChildren->size();
	
	/* Now update all children */
	for (int i = 0; i < curSize; ++i) {				
		TMViewChildPtr& obj = m_pChildren->at(i);
		
		[(id<TMLogicUpdater>)*obj update:fDelta];
		
		// To be safe we must update the curSize everytime
		curSize = m_pChildren->size();
	}
}

/* TMGameUIResponder stuff */
- (BOOL) tmTouchesBegan:(const TMTouchesVec&)touches withEvent:(UIEvent*)event {	
	TMTouch touch = touches.at(0);
	CGPoint point = CGPointMake(touch.x(), touch.y());
		
	if(CGRectContainsPoint(m_rShape, point)) {
		if(m_bEnabled && m_bVisible) {

			// Forward to children
			if(! m_pControls->empty() ) {			
				int curSize = m_pControls->size();
				
				for (int i = 0; i < curSize; ++i) {				
					NSObject* obj = *(m_pControls->at(i));
					[(id<TMGameUIResponder>)obj tmTouchesBegan:touches withEvent:event];
					curSize = m_pControls->size();	// To be safe
				}	
			}				
			
			return YES;
		}
	}
	
	return NO;
}

- (BOOL) tmTouchesMoved:(const TMTouchesVec&)touches withEvent:(UIEvent*)event {	
	TMTouch touch = touches.at(0);
	CGPoint point = CGPointMake(touch.x(), touch.y());
		
	if(CGRectContainsPoint(m_rShape, point)) {
		if(m_bEnabled && m_bVisible) {
			
			// Forward to children
			if(! m_pControls->empty() ) {			
				int curSize = m_pControls->size();
				
				for (int i = 0; i < curSize; ++i) {				
					NSObject* obj = *(m_pControls->at(i));
					[(id<TMGameUIResponder>)obj tmTouchesMoved:touches withEvent:event];
					curSize = m_pControls->size();	// To be safe
				}	
			}				
			
			return YES;
		}
	}
	
	return NO;
}

- (BOOL) tmTouchesEnded:(const TMTouchesVec&)touches withEvent:(UIEvent*)event {	
	TMTouch touch = touches.at(0);
	CGPoint point = CGPointMake(touch.x(), touch.y());
	
	if(CGRectContainsPoint(m_rShape, point)) {
		if(m_bEnabled && m_bVisible) {
			
			// Forward to children
			if(! m_pControls->empty() ) {			
				int curSize = m_pControls->size();
				
				for (int i = 0; i < curSize; ++i) {				
					NSObject* obj = *(m_pControls->at(i));
					[(id<TMGameUIResponder>)obj tmTouchesEnded:touches withEvent:event];
					curSize = m_pControls->size();	// To be safe
				}	
			}				
			
			return YES;
		}
	}
	
	return NO;
}

@end
