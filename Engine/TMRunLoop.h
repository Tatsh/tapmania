//
//  TMRunLoop.h
//  TapMania
//
//  Created by Alex Kremer on 26.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMRenderable.h"
#import "TMLogicUpdater.h"

/* Gradation between NormalLower and NormalUpper is possible */
typedef enum {
	kRunLoopPriority_Lowest = 0,
	kRunLoopPriority_NormalLower = 1,
	kRunLoopPriority_NormalMid = 512,
	kRunLoopPriority_NormalUpper = 1023,
	kRunLoopPriority_Highest = 1024	
} TMRunLoopPriority;

@protocol TMRunLoopDelegate
@optional
- (void) runLoopInitHook;
- (void) runLoopBeforeHook:(NSNumber*)fDelta;
- (void) runLoopAfterHook:(NSNumber*)fDelta;

- (void) runLoopInitializedNotification;
@end


@interface TMRunLoop : NSObject {
	
	// Array to hold the objects which will be used for rendering/updating
	// This array is always sorted from hightest to lowest priority
	NSMutableArray * objects;
	
	// Holds tasks which are performed once and removed from the list afterwards
	NSMutableArray * singleTimeTasks;
	
	// Delegate with before/after hooks
	id delegate;
	
	// Run loop can be stopped using this flag
	@private 
	BOOL _stopRequested;
	BOOL _actualStopState;
}

@property (assign) id <TMRunLoopDelegate> delegate;


// Call this method to run the runloop
- (void) run;

// Request a stop of the looping
- (void) stop;
- (BOOL) isStopped;

// The next routine is used to add renderables or logic updaters to the corresponding array
- (void) registerObject:(NSObject*) obj withPriority:(TMRunLoopPriority) priority;
- (void) deregisterAllObjects;

// Add single time tasks. The order of task performing is FIFO
- (void) registerSingleTimeTask:(NSObject*) task;

@end
