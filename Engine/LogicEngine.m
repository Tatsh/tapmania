//
//  LogicEngine.m
//  TapMania
//
//  Created by Alex Kremer on 01.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "LogicEngine.h"

#import "RenderEngine.h"

// This is a singleton class, see below
static LogicEngine *sharedLogicEngineDelegate = nil;

@implementation LogicEngine


- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	// Create the logic updater loop
	logicRunLoop = [[TMRunLoop alloc] initWithName:@"Logic" andLock:[RenderEngine sharedInstance].renderLock];
	
	logicRunLoop.delegate = self;;
	[logicRunLoop run];	
	
	return self;
}


- (void) registerLogicUpdater:(NSObject*) logicUpdater withPriority:(TMRunLoopPriority) priority {
	[logicRunLoop registerObject:logicUpdater withPriority:priority];
}

- (void) clearLogicUpdaters {
	[logicRunLoop deregisterAllObjects];
}

/* Run loop delegate work */
- (void) runLoopInitHook {
	NSLog(@"Init separate logic thread...");
	[NSThread setThreadPriority:1.0];
}

- (void) runLoopInitializedNotification {
}

- (void) runLoopAfterHook:(NSNumber*)fDelta {
	// Give other threads some extra more time to focus on their job
	[NSThread sleepForTimeInterval:0.0001f];
}

- (void) runLoopActionHook:(NSArray*)args {
	NSObject* obj = [args objectAtIndex:0];
	NSNumber* fDelta = [args objectAtIndex:1];
	
	if([obj conformsToProtocol:@protocol(TMLogicUpdater)]){
		
		// Call the update method on the object
		[obj performSelector:@selector(update:) withObject:fDelta];
		
	} else {
		NSException* ex = [NSException exceptionWithName:@"UnknownObjType" 
											  reason:[NSString stringWithFormat:
													  @"The object you have passed [%@] into the runLoop doesn't conform to protocol [%s].", 
													  [obj class], [@protocol(TMLogicUpdater) name]] 
											userInfo:nil];
		@throw(ex);
	}	
}


#pragma mark Singleton stuff

+ (LogicEngine *)sharedInstance {
    @synchronized(self) {
        if (sharedLogicEngineDelegate == nil) {
            [[self alloc] init];
        }
    }
    return sharedLogicEngineDelegate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedLogicEngineDelegate	== nil) {
            sharedLogicEngineDelegate = [super allocWithZone:zone];
            return sharedLogicEngineDelegate;
        }
    }
	
    return nil;
}


- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
	// NOTHING
}

- (id)autorelease {
    return self;
}

@end
