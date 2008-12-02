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
#import "RenderEngine.h"
#import "TMLogicUpdater.h"
#import "TimingUtil.h"

#import "BenchmarkUtil.h"

#import <syslog.h>

@interface TMRunLoop (Private)
- (void) worker; // The real thread's working routine
@end

@implementation TMRunLoop

@synthesize delegate, thread;

- (id) initWithName:(NSString*)lName andLock:(NSLock*)lLock {
	self = [super init];
	if(!self)
		return nil;

	objects = [[NSMutableArray arrayWithCapacity:1] retain];
	singleTimeTasks = [[NSMutableArray arrayWithCapacity:1] retain];
	
	_stopRequested = NO;
	_actualStopState = YES; // Initially stopped
	
	name = lName;
	lock = lLock;
	objectsLock = [[NSLock alloc] init];
	tasksLock = [[NSLock alloc] init];
	
	thread = [[NSThread alloc] initWithTarget:self selector:@selector(worker) object:nil];
	
	return self;
}

- (void) dealloc {
	[objects release];
	[singleTimeTasks release];
	
	[super dealloc];
}

- (void) run {
	
	NSLog(@"Run the %@ RunLoop thread.", name);
	
	[thread start];
	_actualStopState = NO; // Running
	
	NSLog(@"Thread is now running.");
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
	
	[objectsLock lock];
	
	int i;
	for(i=0; i<[objects count]; i++){
		if([(TMObjectWithPriority*)[objects objectAtIndex:i+1] priority] < priority) {
			break;
		}
	}
	
	// Add new object at 'i' and shift others if required
	TMObjectWithPriority* wrapper = [[TMObjectWithPriority alloc] initWithObj:obj andPriority:priority];
	[objects insertObject:wrapper atIndex:i];	
	
	[objectsLock unlock];
}

- (void) deregisterAllObjects {
	[objectsLock lock];
	
	int i;
	for(i=0; i<[objects count]; i++){
		TMObjectWithPriority* obj = [objects objectAtIndex:i];
		[obj release];
	}	
	
	[objects removeAllObjects];
	
	[objectsLock unlock];
}

- (void) registerSingleTimeTask:(NSObject*) task {
	[tasksLock lock];
	[singleTimeTasks addObject:task]; // Add to the end
	[tasksLock unlock];
}

/* Private worker */
- (void) worker {
	int framesCounter = 0;
	float prevTime = [TimingUtil getCurrentTime] - 1.0f;
	float totalTime = 0.0f;

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
	/* Call initialization routine on delegate */
	if(delegate && [delegate respondsToSelector:@selector(runLoopInitHook)]) {
		[delegate performSelector:@selector(runLoopInitHook) onThread:thread withObject:nil waitUntilDone:YES];
		
		if([delegate respondsToSelector:@selector(runLoopInitializedNotification)]){
			[delegate performSelector:@selector(runLoopInitializedNotification) onThread:thread withObject:nil waitUntilDone:YES];
		}
	}
	
	// TODO: pereodic pool releases must be added
	
	while (!_stopRequested) {
		float currentTime = [TimingUtil getCurrentTime];
		
		// BenchmarkUtil *bm = [BenchmarkUtil instanceWithName:name];
		
		
		float delta = currentTime-prevTime;
		NSNumber* nDelta = [NSNumber numberWithFloat:delta];
		
		prevTime = currentTime;
		
		totalTime += delta;
		
		if(totalTime > 1.0f) {
			// Show fps
			framesCounter/=totalTime;
			// NSLog(@"[RunLoop %@] FPS: %d", name, framesCounter);			
			// syslog(LOG_DEBUG, "[RunLoop %s] FPS: %d", [name UTF8String], framesCounter);
			
			totalTime = 0.0f;
			framesCounter = 0;
		}
		
		framesCounter ++;
		
		 
		/* Now call the runLoopBeforeHook method on the delegate */
		if(delegate && [delegate respondsToSelector:@selector(runLoopBeforeHook:)]) { 
			[delegate performSelector:@selector(runLoopBeforeHook:) onThread:thread withObject:nDelta waitUntilDone:YES];
		}
		
		[tasksLock lock];
		
		/* Perform all pending single time tasks first */
		unsigned i;
		for(i=0; i<[singleTimeTasks count]; i++){
			if(delegate){
				NSObject* task = [singleTimeTasks objectAtIndex:i];
				
				[lock lock];
				[delegate performSelector:@selector(runLoopSingleTimeTaskActionHook:withDelta:) withObject:task withObject:nDelta];
				[lock unlock];	
			}
		}
		
		// Remove all tasks from the list now
		[singleTimeTasks removeAllObjects];
		
		[tasksLock unlock];
		[objectsLock lock];
		
		/* Do the actual work */
		for(i=0; i<[objects count]; i++){
			TMObjectWithPriority* wrapper = [objects objectAtIndex:i];
			NSObject* obj = [wrapper obj];
			
			if(delegate) {
				/* We must call the action method on the delegate now */
				[lock lock];
				[delegate performSelector:@selector(runLoopActionHook:withDelta:) withObject:obj withObject:nDelta];
				[lock unlock];
			}
		}

		[objectsLock unlock];
		
		/* Now call the runLoopAfterHook method on the delegate */
		if(delegate && [delegate respondsToSelector:@selector(runLoopAfterHook:)]) { 
			[delegate performSelector:@selector(runLoopAfterHook:) onThread:thread withObject:nDelta waitUntilDone:YES];
		}
		
	//	[bm finish];
	}
	
	[pool drain];
	
	// Mark as stopped
	_actualStopState = YES;
}

@end
