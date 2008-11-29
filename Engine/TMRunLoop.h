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

// Must have this method
- (void) runLoopActionHook:(NSArray*)args;	// 1st - object, 2nd - delta time

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

	// Delegate with before/after hooks
	id delegate;
	
	// Run loop can be stopped using this flag
	@private 
	BOOL _stopRequested;
	BOOL _actualStopState;
		
	// Every run loop has a name
	NSString* name;
	
	// The lock used to synchronize threads
	NSLock* lock;
	
	// The thread object
	NSThread* thread;
}

@property (assign) id <TMRunLoopDelegate> delegate;
@property (retain, readonly, nonatomic) NSThread* thread;

// Constructors
- (id) initWithName:(NSString*)lName andLock:(NSLock*)lLock;

// Call this method to run the runloop
- (void) run;

// Request a stop of the looping
- (void) stop;
- (BOOL) isStopped;

// The next routine is used to add renderables or logic updaters to the corresponding array
- (void) registerObject:(NSObject*) obj withPriority:(TMRunLoopPriority) priority;
- (void) deregisterAllObjects;

@end
