//
//  $Id$
//  TMRunLoop.m
//  TapMania
//
//  Created by Alex Kremer on 26.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMRunLoop.h"

#import "TMRenderable.h"
#import "TMLogicUpdater.h"
#import "TimingUtil.h"
#import "TapMania.h"
#import "MessageManager.h"
#import "TMMessage.h"
#import "TMCommand.h"

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

- (void) pushBackChild:(NSObject*)inChild {
	m_aObjects->push_back(inChild);
}

- (void) pushChild:(NSObject*)inChild {
	m_aObjects->push_front(inChild);
}

- (void) removeObject:(NSObject*) obj {
	TMObjList::iterator it;
	
	if( ! m_aObjects->empty() ) {
		for (it = m_aObjects->begin(); it != m_aObjects->end(); ++it) {
			if( *it == obj ) {
				m_aObjects->erase(it);
				return;
			}
		}
	}	
}

- (void) removeAllObjects {
	TMObjList::iterator it;
		
	if( ! m_aObjects->empty() ) {
		for (it = m_aObjects->begin(); it != m_aObjects->end(); ++it) {
			[*it release];
			m_aObjects->erase(it);
		}
	}
}

/**
 * This method removes all the TMCommands which are working with the
 * object specified as argument.
 */
- (void) removeCommandsForObject:(NSObject*) obj {
	TMObjList::iterator it;
	
	if( ! m_aObjects->empty() ) {
		for (it = m_aObjects->begin(); it != m_aObjects->end();) {
			if([*it isKindOfClass:[TMCommand class]] && [(TMCommand*)*it getInvocationObject]==obj) {
				TMLog(@"Found command which works with the object.. remove.");
				it = m_aObjects->erase(it);
			} else ++it;
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
				NSObject* obj = m_aObjects->at(i);
				[(id<TMLogicUpdater>)obj update:delta];
				curSize = m_aObjects->size();	// To be safe
			}	
				
			curSize = m_aObjects->size();
			
			/* Now draw all objects */
			for (int i = 0; i < curSize; ++i) {				
				NSObject* obj = m_aObjects->at(i);				
				[(id<TMRenderable>)obj render:delta];
				curSize = m_aObjects->size();
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
	switch (message.messageId) {
		case kApplicationShouldTerminateMessage:
			[self stop];
			break;
	}
}

@end
