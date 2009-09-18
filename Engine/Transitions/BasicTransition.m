//
//  BasicTransition.m
//  TapMania
//
//  Created by Alex Kremer on 02.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "BasicTransition.h"
#import "TMTransitionSupport.h"
#import "TMScreen.h"
#import "TapMania.h"
#import "InputEngine.h"
#import "TMRunLoop.h"	// For TMRunLoopPriority
#import "TimingUtil.h"

@implementation BasicTransition

- (id) initFromScreen:(TMScreen*)fromScreen toScreen:(TMScreen*)toScreen timeIn:(double)timeIn timeOut:(double)timeOut {
	self = [self initFromScreen:fromScreen toScreen:toScreen];
	if(!self)
		return nil;
	
	m_dTimeIn = timeIn;
	m_dTimeOut = timeOut;
	
	return self;
}

- (id) initFromScreen:(TMScreen*)fromScreen toScreen:(TMScreen*)toScreen {
	self = [super init];
	if (!self)
		return nil;
	
	m_pFrom = fromScreen;
	m_pTo = toScreen;
	m_dElapsedTime = 0.0;
	m_nState = kTransitionStateInitializing;
	
	m_dTimeIn = kDefaultTransitionInTime;
	m_dTimeOut = kDefaultTransitionOutTime;

	return self;
}

// May override in animating transitions
- (BOOL) updateTransitionIn {
	m_dElapsedTime = [TimingUtil getCurrentTime] - m_dTimeStart;
	if(m_dElapsedTime >= m_dTimeIn)
		return YES;
	return NO;
}

- (BOOL) updateTransitionOut {
	m_dElapsedTime = [TimingUtil getCurrentTime] - m_dTimeStart;
	if(m_dElapsedTime >= m_dTimeOut)
		return YES;
	return NO;
}

// TMTransition stuff. can be overriden to do some special stuff.
- (void) transitionInStarted {
	// Disable the dispatcher so that we don't mess around with random taps
	[[InputEngine sharedInstance] disableDispatcher];
	
	if([m_pFrom conformsToProtocol:@protocol(TMTransitionSupport)]  && [m_pFrom respondsToSelector:@selector(beforeTransition)]){
		[m_pFrom performSelector:@selector(beforeTransition)];
	}		
}

- (void) transitionOutStarted {	
	TMLog(@"Do custom initialization for transition out...");
	
	// Do custom initialization for transition if the object supports it
	if([m_pTo conformsToProtocol:@protocol(TMTransitionSupport)]){
		[m_pTo performSelector:@selector(setupForTransition)];
	}	
	
	TMLog(@"Transition out animation started...");
	
	// Set new one and show it
	[[TapMania sharedInstance] setCurrentScreen:m_pTo];
	TMLog(@"Transition out set current screen done");
	[[TapMania sharedInstance] registerObjectAtBegin:(NSObject*)m_pTo];	
	TMLog(@"Transition out register object done");
}

- (void) transitionInFinished {
	// Do custom deinitialization for transition if the object supports it
	if(m_pFrom != nil) {
		if([m_pFrom conformsToProtocol:@protocol(TMTransitionSupport)]){
			[m_pFrom performSelector:@selector(deinitOnTransition)];
		}	
	
		// Remove the current screen from rendering/logic runloop.
		[[TapMania sharedInstance] deregisterObject:(NSObject*)m_pFrom];	
	
		// Drop current screen
		[[TapMania sharedInstance] releaseCurrentScreen];
	}
}

- (void) transitionOutFinished {
	TMLog(@"Transition out finished...");
	
	// Remove our transition from runloop
	[[TapMania sharedInstance] deregisterObject:self];
	
	TMLog(@"Removed self from runloop");
	
	// Enable the dispatcher so that we can mess again :P
	[[InputEngine sharedInstance] enableDispatcher];
	
	TMLog(@"m_pTo = %@", m_pTo);
	
	if([m_pTo conformsToProtocol:@protocol(TMTransitionSupport)] && [m_pTo respondsToSelector:@selector(afterTransition)]){
		[m_pTo performSelector:@selector(afterTransition)];
	}			
}

// TMRenderable stuff
- (void)render:(float)fDelta {	
	// OVERRIDE
}

// TMLogicUpdater stuff. should not override in subclasses.
- (void)update:(float)fDelta {	
	switch(m_nState) {
		case kTransitionStateInitializing:
			// Start transition
			[self transitionInStarted];
		
			m_nState = kTransitionStateIn;
			m_dTimeStart = [TimingUtil getCurrentTime];
			break;
			
		case kTransitionStateIn:
			// Do calculation
			if( [self updateTransitionIn] ) {
			
				// Switch to Out transition part
				[self transitionInFinished];
				[self transitionOutStarted];
				m_nState = kTransitionStateOut;
				m_dTimeStart = [TimingUtil getCurrentTime];
			}			
			break;
			
		case kTransitionStateOut:
			// Do calculation
			if ( [self updateTransitionOut] ) {
				
				// Switch to finish
				[self transitionOutFinished];
				m_nState = kTransitionStateFinished;
			}
			break;
	}
}

@end
