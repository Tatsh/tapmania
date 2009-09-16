//
//  TMScreen.m
//  TapMania
//
//  Created by Alex Kremer on 10.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMScreen.h"
#import "InputEngine.h"


@implementation TMScreen

- (id) init {
	self = [super init];
	if(!self)
		return nil;

	m_pChildren = new TMScreenChildren();
		
	return self;
}

-(void) pushBackChild:(NSObject*)inChild {
	m_pChildren->push_back(inChild);	
}

-(void) pushChild:(NSObject*)inChild {
	m_pChildren->push_front(inChild);	
}

-(void) pushBackControl:(NSObject*)inChild {
	[self pushBackChild:inChild];

	[[InputEngine sharedInstance] subscribe:inChild];
}

-(NSObject*) popBackChild {
	if(m_pChildren->empty())
		return nil;
	
	NSObject* objPtr = m_pChildren->back();
	m_pChildren->pop_back();
	
	[[InputEngine sharedInstance] unsubscribe:objPtr];
	return objPtr;
}

-(NSObject*) popChild {
	if(m_pChildren->empty())
		return nil;
	
	NSObject* objPtr = m_pChildren->front();
	m_pChildren->pop_front();

	[[InputEngine sharedInstance] unsubscribe:objPtr];

	return objPtr;	
}

- (void) dealloc {
	TMLog(@"Deallocating TMScreen instance...");
	NSObject* p = nil;
	
	while( nil != ( p = [self popChild] ) ) {
		TMLog(@"Releasing %@", p);
		[p release];
	}
	
	delete m_pChildren;
	TMLog(@"Done.");
	
	[super dealloc];
}

/* TMTransitionSupport methods */
- (void) setupForTransition {

}

- (void) deinitOnTransition {

}

/* TMRenderable method */
- (void) render:(float)fDelta {
	int curSize = m_pChildren->size();
	
	/* Now draw all children */
	for (int i = 0; i < curSize; ++i) {				
		NSObject* obj = m_pChildren->at(i);
	
		[(id<TMRenderable>)obj render:fDelta];
	
		// To be safe we must update the curSize everytime
		curSize = m_pChildren->size();
	}
}

/* TMLogicUpdater stuff */
- (void) update:(float)fDelta {
	int curSize = m_pChildren->size();
	
	/* Now update all children */
	for (int i = 0; i < curSize; ++i) {				
		NSObject* obj = m_pChildren->at(i);
		
		[(id<TMLogicUpdater>)obj update:fDelta];
			
		// To be safe we must update the curSize everytime
		curSize = m_pChildren->size();
	}
}

@end

