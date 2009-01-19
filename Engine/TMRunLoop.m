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

@synthesize delegate;

- (id) init {
	self = [super init];
	if(!self)
		return nil;

	objects = [[NSMutableArray arrayWithCapacity:1] retain];
	singleTimeTasks = [[NSMutableArray arrayWithCapacity:1] retain];
	
	_stopRequested = NO;
	_actualStopState = YES; // Initially stopped
		
	return self;
}

- (void) dealloc {
	[objects release];
	[singleTimeTasks release];
	
	[super dealloc];
}

- (void) run {
	_actualStopState = NO; // Running
	[self worker];
}

- (void) stop {
	_stopRequested = YES;
}

- (BOOL) isStopped {
	return _actualStopState;
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
	if([objects count] > 0) {
		for(i=0; i<([objects count])-1; i++){
			if([(TMObjectWithPriority*)[objects objectAtIndex:i+1] priority] < priority) {
				break;
			}
		}
	}
	
	// Add new object at 'i' and shift others if required
	TMObjectWithPriority* wrapper = [[TMObjectWithPriority alloc] initWithObj:obj andPriority:priority];
	[objects insertObject:wrapper atIndex:i];	
}

- (void) deregisterAllObjects {
	int i;
	for(i=0; i<[objects count]; i++){
		TMObjectWithPriority* obj = [objects objectAtIndex:i];
		[obj release];
	}	
	
	[objects removeAllObjects];
}

- (void) registerSingleTimeTask:(NSObject*) task {
	[singleTimeTasks addObject:task]; // Add to the end
}

/* Private worker */
- (void) worker {
	// int framesCounter = 0;
	float prevTime = [TimingUtil getCurrentTime] - 1.0f;
	// float totalTime = 0.0f;

	/* Call initialization routine on delegate */
	if(delegate && [delegate respondsToSelector:@selector(runLoopInitHook)]) {
		[delegate performSelector:@selector(runLoopInitHook) withObject:nil];
		
		if([delegate respondsToSelector:@selector(runLoopInitializedNotification)]){
			[delegate performSelector:@selector(runLoopInitializedNotification) withObject:nil];
		}
	}
	
	while (!_stopRequested) {
		float currentTime = [TimingUtil getCurrentTime];
		
		float delta = currentTime-prevTime;
		NSNumber* nDelta = [NSNumber numberWithFloat:delta];
		
		prevTime = currentTime;
		
		/*
		totalTime += delta;
		
		if(totalTime > 1.0f) {
			// Show fps
			framesCounter/=totalTime;
			// NSLog(@"[RunLoop] FPS: %d", framesCounter);			
			// syslog(LOG_DEBUG, "[RunLoop] FPS: %d", framesCounter);
			
			totalTime = 0.0f;
			framesCounter = 0;
		}
		
		framesCounter ++;
		*/
		
		/* Now call the runLoopBeforeHook method on the delegate */
		if(delegate && [delegate respondsToSelector:@selector(runLoopBeforeHook:)]) { 
			[delegate performSelector:@selector(runLoopBeforeHook:) withObject:nDelta];
		}
		
		/* Perform all pending single time tasks first */
		unsigned i;
		for(i=0; i<[singleTimeTasks count]; i++){		
			NSObject* task = [singleTimeTasks objectAtIndex:i];
			if([task conformsToProtocol:@protocol(TMSingleTimeTask)]){
				[task performSelector:@selector(action:) withObject:nDelta];
			} 				
		}
		
		// Remove all tasks from the list now
		[singleTimeTasks removeAllObjects];
		
		/* Do the actual work */
		/* First update all objects */
		for(i=0; i<[objects count]; i++){
			TMObjectWithPriority* wrapper = [objects objectAtIndex:i];
			NSObject* obj = [wrapper obj];
			
			if([obj conformsToProtocol:@protocol(TMLogicUpdater)]) {
				[obj performSelector:@selector(update:) withObject:nDelta];
			}
		}

		/* Now draw all objects */
		for(i=0; i<[objects count]; i++){
			TMObjectWithPriority* wrapper = [objects objectAtIndex:i];
			NSObject* obj = [wrapper obj];
			
			if([obj conformsToProtocol:@protocol(TMRenderable)]) {
				[obj performSelector:@selector(render:) withObject:nDelta];
			}
		}
		
		/* Now call the runLoopAfterHook method on the delegate */
		if(delegate && [delegate respondsToSelector:@selector(runLoopAfterHook:)]) { 
			[delegate performSelector:@selector(runLoopAfterHook:) withObject:nDelta];
		}		
	}
	
	// Mark as stopped
	_actualStopState = YES;
}

@end
