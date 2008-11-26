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

@interface TMRunLoop (Private)
- (void) worker; // The real thread's working routine
@end

@implementation TMRunLoop

@synthesize delegate;

- (id) initWithName:(NSString*)lName type:(id)lType andLock:(NSLock*)lLock {
	self = [super init];
	if(!self)
		return nil;
	
	objects = [[NSMutableArray arrayWithCapacity:1] retain];
	
	_stopRequested = NO;
	_actualStopState = YES; // Initially stopped

	name = lName;
	protocolType = lType;
	lock = lLock;
	
	return self;
}

- (void) dealloc {
	[objects release];
	
	[super dealloc];
}

- (void) run {
	
	NSLog(@"Run the %@ RunLoop thread.", name);
	
	thread = [[NSThread alloc] initWithTarget:self selector:@selector(worker) object:nil];
	
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
	
	int i;
	for(i=0; i<[objects count]; i++){
		if([(TMObjectWithPriority*)[objects objectAtIndex:i+1] priority] < priority) {
			break;
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
		[[obj obj] release];
		[obj release];
	}	
	
	[objects removeAllObjects];
}

/* Private worker */
- (void) worker {
	int framesCounter = 0;
	float prevTime = [TimingUtil getCurrentTime] - 1.0f;
	float totalTime = 0.0f;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	/* Call initialization routine on delegate */
	if(delegate && [delegate respondsToSelector:@selector(runLoopInitHook)]) {
		[delegate runLoopInitHook];
	}
	
	// TODO: pereodic pool releases must be added
	
	while (!_stopRequested) {
		float currentTime = [TimingUtil getCurrentTime];
		float delta = currentTime-prevTime;
		prevTime = currentTime;
		totalTime += delta;
		
		if(totalTime > 1.0f) {
			// Show fps
			NSLog(@"[RunLoop %@] FPS: %d", name, framesCounter);			
			
			totalTime = 0.0f;
			framesCounter = 0;
		}
		
		framesCounter ++;
		
		/* Now call the runLoopBeforeHook method on the delegate */
		if(delegate && [delegate respondsToSelector:@selector(runLoopBeforeHook)]) { 
			[delegate runLoopBeforeHook:delta]; 
		}
		
		/* Do the actual work */
		unsigned i;
		for(i=0; i<[objects count]; i++){
			TMObjectWithPriority* wrapper = [objects objectAtIndex:i];
			NSObject* obj = [wrapper obj];
			BOOL actionCompleted = NO;
			
			// TODO: fix warnings below
			// TODO: isEqual: doesn't work for some reason.
			
			if(!strcmp([protocolType name], [@protocol(TMLogicUpdater) name]) && [obj conformsToProtocol:@protocol(TMLogicUpdater)]) {
				// Call the update method
				[lock lock];
				[obj update:delta];
				[lock unlock];
				
				actionCompleted = YES;
			}
			
			if(!strcmp([protocolType name], [@protocol(TMRenderable) name]) && [obj conformsToProtocol:@protocol(TMRenderable)]){
				// Call the render method
				[lock lock];
				[obj render:delta];
				[lock unlock];
				
				actionCompleted = YES;
			} 
			
			// Handle situation with odd objects which are neither renderable nor logic updaters
			if(!actionCompleted) {
				NSException* ex = [NSException exceptionWithName:@"UnknownObjType" 
										reason:[NSString stringWithFormat:
												@"The object you have passed [%@] into the runLoop is not of type [%s].", [obj className], [protocolType name]] 
										userInfo:nil];
				@throw(ex);
			}
		}
		
		/* Now call the runLoopAfterHook method on the delegate */
		if(delegate && [delegate respondsToSelector:@selector(runLoopAfterHook)]) { 
			[delegate runLoopAfterHook:delta]; 
		}		
		
	}
	
	[pool drain];
	
	// Mark as stopped
	_actualStopState = YES;
}

@end
