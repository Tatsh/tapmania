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

-(void) pushBackChild:(NSObject*)inChild {
	m_pChildren->push_back( TMViewChildPtr( inChild ) );	
}

-(void) pushChild:(NSObject*)inChild {
	m_pChildren->push_front( TMViewChildPtr( inChild ) );	
}

-(void) pushBackControl:(NSObject*)inChild {
	[self pushBackChild:inChild];
	
	[[InputEngine sharedInstance] subscribe:inChild];
}

-(NSObject*) popBackChild {
	if(m_pChildren->empty())
		return nil;
	
	TMViewChildPtr objPtr = m_pChildren->back();
	m_pChildren->pop_back();
	
	[[InputEngine sharedInstance] unsubscribe:*objPtr];
	return *objPtr;
}

-(NSObject*) popChild {
	if(m_pChildren->empty())
		return nil;
	
	TMViewChildPtr objPtr = m_pChildren->front();
	m_pChildren->pop_front();
	
	[[InputEngine sharedInstance] unsubscribe:*objPtr];
	
	return *objPtr;	
}

- (void) dealloc {
	TMLog(@"Deallocating TMView instance...");
	delete m_pChildren;
	TMLog(@"Done.");
	
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
		if(m_bEnabled && m_bVisible) 
			return YES;
	}
	
	return NO;
}

- (BOOL) tmTouchesMoved:(const TMTouchesVec&)touches withEvent:(UIEvent*)event {	
	TMTouch touch = touches.at(0);
	CGPoint point = CGPointMake(touch.x(), touch.y());
		
	if(CGRectContainsPoint(m_rShape, point)) {
		if(m_bEnabled && m_bVisible) 
			return YES;
	}
	
	return NO;
}

- (BOOL) tmTouchesEnded:(const TMTouchesVec&)touches withEvent:(UIEvent*)event {	
	TMTouch touch = touches.at(0);
	CGPoint point = CGPointMake(touch.x(), touch.y());
	
	if(CGRectContainsPoint(m_rShape, point)) {
		if(m_bEnabled && m_bVisible) 
			return YES;
	}
	
	return NO;
}

@end
