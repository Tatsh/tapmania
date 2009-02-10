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
#import "TMSingleTimeTask.h"
#import "TapMania.h"
#import <syslog.h>

@interface TMRunLoop (Private)
- (void) worker; 
@end

@implementation TMRunLoop

@synthesize m_idDelegate;

- (id) init {
	self = [super init];
	if(!self)
		return nil;

	m_aObjects = [[NSMutableArray arrayWithCapacity:1] retain];
	m_aSingleTimeTasks = [[NSMutableArray arrayWithCapacity:1] retain];
	
	m_bStopRequested = NO;
	m_bActualStopState = YES; // Initially stopped
		
	return self;
}

- (void) dealloc {
	[m_aObjects release];
	[m_aSingleTimeTasks release];
	
	[super dealloc];
}

- (void) run {
	m_bActualStopState = NO; // Running
	[self worker];
}

- (void) stop {
	m_bStopRequested = YES;
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
	
	int i = 0;
	if([m_aObjects count] > 0) {
		for(i=0; i<([m_aObjects count])-1; i++){
			if([(TMObjectWithPriority*)[m_aObjects objectAtIndex:i+1] m_uPriority] < priority) {
				break;
			}
		}
	}
	
	// Add new object at 'i' and shift others if required
	TMObjectWithPriority* wrapper = [[TMObjectWithPriority alloc] initWithObj:obj andPriority:priority];
	[m_aObjects insertObject:wrapper atIndex:i];	
}

- (void) deregisterAllObjects {
	int i;
	for(i=0; i<[m_aObjects count]; i++){
		TMObjectWithPriority* obj = [m_aObjects objectAtIndex:i];
		[obj release];
	}	
	
	[m_aObjects removeAllObjects];
}

- (void) registerSingleTimeTask:(NSObject*) task {
	[m_aSingleTimeTasks addObject:task]; // Add to the end
}

/* Private worker */
- (void) worker {
	// int framesCounter = 0;
	float prevTime = [TimingUtil getCurrentTime] - 1.0f;
	// float totalTime = 0.0f;

	/* Call initialization routine on delegate */
	if(m_idDelegate && [m_idDelegate respondsToSelector:@selector(runLoopInitHook)]) {
		[m_idDelegate performSelector:@selector(runLoopInitHook) withObject:nil];
		
		if([m_idDelegate respondsToSelector:@selector(runLoopInitializedNotification)]){
			[m_idDelegate performSelector:@selector(runLoopInitializedNotification) withObject:nil];
		}
	}
	
	while (!m_bStopRequested) {
		float currentTime = [TimingUtil getCurrentTime];
		
		float delta = currentTime-prevTime;
		NSNumber* nDelta = [NSNumber numberWithFloat:delta];
		
		prevTime = currentTime;
		
		/*
		totalTime += delta;
		
		if(totalTime > 1.0f) {
			// Show fps
			framesCounter/=totalTime;		
			// TMLog(@"[RunLoop] FPS: %d", framesCounter);
			
			totalTime = 0.0f;
			framesCounter = 0;
		}
		
		framesCounter ++;
		*/
		
		/* Now call the runLoopBeforeHook method on the delegate */
		if(m_idDelegate && [m_idDelegate respondsToSelector:@selector(runLoopBeforeHook:)]) { 
			[m_idDelegate performSelector:@selector(runLoopBeforeHook:) withObject:nDelta];
		}
		
		/* Perform all pending single time tasks first */
		unsigned i;
		for(i=0; i<[m_aSingleTimeTasks count]; i++){		
			NSObject* task = [m_aSingleTimeTasks objectAtIndex:i];
			if([task conformsToProtocol:@protocol(TMSingleTimeTask)]){
				[task performSelector:@selector(action:) withObject:nDelta];
			} 				
		}
		
		// Remove all tasks from the list now
		[m_aSingleTimeTasks removeAllObjects];
		
		/* Do the actual work */
		/* First update all objects */
		for(i=0; i<[m_aObjects count]; i++){
			TMObjectWithPriority* wrapper = [m_aObjects objectAtIndex:i];
			NSObject* obj = [wrapper m_pObj];
			
			if([obj conformsToProtocol:@protocol(TMLogicUpdater)]) {
				[obj performSelector:@selector(update:) withObject:nDelta];
			}
		}

		/* Now draw all objects */
		for(i=0; i<[m_aObjects count]; i++){
			TMObjectWithPriority* wrapper = [m_aObjects objectAtIndex:i];
			NSObject* obj = [wrapper m_pObj];
			
			if([obj conformsToProtocol:@protocol(TMRenderable)]) {
				[obj performSelector:@selector(render:) withObject:nDelta];
			}
		}
		
		/* Now call the runLoopAfterHook method on the delegate */
		if(m_idDelegate && [m_idDelegate respondsToSelector:@selector(runLoopAfterHook:)]) { 
			[m_idDelegate performSelector:@selector(runLoopAfterHook:) withObject:nDelta];
		}		
	}
	
	// Mark as stopped
	m_bActualStopState = YES;
}

@end
