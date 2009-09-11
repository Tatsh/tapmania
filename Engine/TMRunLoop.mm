//
//  TMRunLoop.m
//  TapMania
//
//  Created by Alex Kremer on 26.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMRunLoop.h"

#import "TMObjectWithPriority.h"
#import "TMRenderable.h"
#import "TMLogicUpdater.h"
#import "TimingUtil.h"
#import "TapMania.h"
#import "MessageManager.h"
#import "TMMessage.h"

@interface TMRunLoop (Private)
- (void) worker; 
@end

@implementation TMRunLoop

@synthesize m_idDelegate;

- (id) init {
	self = [super init];
	if(!self)
		return nil;

	m_aObjects = new TMObjList();
	
	m_bStopRequested = NO;
	m_bActualStopState = YES; // Initially stopped
		
	// Subscribe for messages
	SUBSCRIBE(kApplicationShouldTerminateMessage);
	
	return self;
}

- (void) dealloc {
	//[m_aObjects release];
	delete m_aObjects;
	
	[super dealloc];
}

- (void) run {
	m_bActualStopState = NO; // Running
	[self worker];
}

- (void) stop {
	m_bStopRequested = YES;
	UNSUBSCRIBE_ALL();
}

- (BOOL) isStopped {
	return m_bActualStopState;
}

/* Add stuff to the arrays and sort them on the fly */
- (void) registerObject:(NSObject*) obj withPriority:(TMRunLoopPriority) priority {
	// Wrapping of priority
	if (priority < kRunLoopPriority_Lowest) {
		priority = kRunLoopPriority_Lowest;
	} else if (priority > kRunLoopPriority_Highest) {
		priority = kRunLoopPriority_Highest;
	}
	
	TMObjList::iterator it;
		
	if( ! m_aObjects->empty() ) {
		for (it = m_aObjects->begin(); it != m_aObjects->end(); ++it) {
			if([(TMObjectWithPriority*)*it m_uPriority] <= priority) {
				break;
			}
		}
	}
	
	// Add new object at 'i' and shift others if required
	TMObjectWithPriority* wrapper = [[TMObjectWithPriority alloc] initWithObj:obj andPriority:priority];
	if(!m_aObjects->empty() && it != m_aObjects->end()) {
		m_aObjects->insert(it, wrapper);
	} else {
		m_aObjects->push_back(wrapper);
	}
}

- (void) deregisterObject:(NSObject*) obj {
	TMObjList::iterator it;
	
	if( ! m_aObjects->empty() ) {
		for (it = m_aObjects->begin(); it != m_aObjects->end(); ++it) {
			if([(TMObjectWithPriority*)*it m_pObj] == obj) {
				m_aObjects->erase(it);
				return;
			}
		}
	}
}

- (void) deregisterAllObjects {
	TMObjList::iterator it;
		
	if( ! m_aObjects->empty() ) {
		for (it = m_aObjects->begin(); it != m_aObjects->end(); ++it) {
			[*it release];
			m_aObjects->erase(it);
		}
	}
}

/* Private worker */
- (void) worker {
	float prevTime = [TimingUtil getCurrentTime] - 1.0f;

	// We need a delegate
	assert(m_idDelegate != nil);
	
	/* Call initialization routine on delegate */
	if([m_idDelegate respondsToSelector:@selector(runLoopInitHook)]) {
		[m_idDelegate runLoopInitHook];
		
		if([m_idDelegate respondsToSelector:@selector(runLoopInitializedNotification)]){
			[m_idDelegate runLoopInitializedNotification];
		}
	}
	
	while (!m_bStopRequested) {
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		
		float currentTime = [TimingUtil getCurrentTime];
		
		float delta = currentTime-prevTime;		
		prevTime = currentTime;
		
		/* Now call the runLoopBeforeHook method on the delegate */
		[m_idDelegate runLoopBeforeHook:delta];
		
		/* Do the actual work */
		/* First update all objects */
		if(! m_aObjects->empty() ) {			
			int curSize = m_aObjects->size();
			
			for (int i = 0; i < curSize; ++i) {				
				TMObjectWithPriority* wrapper = (TMObjectWithPriority*)(m_aObjects->at(i));
				NSObject* obj = [wrapper m_pObj];

				if([obj conformsToProtocol:@protocol(TMLogicUpdater)]) {
					// Ignore this warning.
					[(id<TMLogicUpdater>)obj update:delta];
					curSize = m_aObjects->size();	// To be safe
				}
			}	
				
			curSize = m_aObjects->size();
			
			/* Now draw all objects */
			for (int i = 0; i < curSize; ++i) {				
				TMObjectWithPriority* wrapper = (TMObjectWithPriority*)(m_aObjects->at(i));
				NSObject* obj = [wrapper m_pObj];
				
				if([obj conformsToProtocol:@protocol(TMRenderable)]) {
					// Ignore this warning.				
					[(id<TMRenderable>)obj render:delta];
					curSize = m_aObjects->size();
				}
			}			
		}
		
		/* Now call the runLoopAfterHook method on the delegate */
		[m_idDelegate runLoopAfterHook:delta];
		
		// Clean up pool
		[pool drain];	// Drain will call release on iPhone
	}
	
	// Mark as stopped
	m_bActualStopState = YES;
	TMLog(@"TMRunLoop stopped!");
}

/* TMMessageSupport stuff */
-(void) handleMessage:(TMMessage*)message {
	TMLog(@"TMRunLoop received message: %d", message.messageId);
	
	switch (message.messageId) {
		case kApplicationShouldTerminateMessage:
			[self stop];
			break;
	}
}

@end
