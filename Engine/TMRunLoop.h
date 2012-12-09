//
//  $Id$
//  TMRunLoop.h
//  TapMania
//
//  Created by Alex Kremer on 26.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMRenderable.h"
#import "TMLogicUpdater.h"
#import "TMMessageSupport.h"

#ifdef __cplusplus

#include <deque>
using namespace std;

typedef deque<NSObject*> TMObjList;

#endif

@protocol TMRunLoopDelegate
@optional
- (void) runLoopInitHook;
- (void) runLoopInitializedNotification;

@required
- (void) runLoopBeforeHook:(float)fDelta;
- (void) runLoopAfterHook:(float)fDelta;
@end


@interface TMRunLoop : NSObject <TMMessageSupport> {
	
	// Array to hold the objects which will be used for rendering/updating
	// This array is always sorted from hightest to lowest priority
#ifdef __cplusplus
	TMObjList		*m_aObjects;
#endif
		
	// Delegate with before/after hooks
	id				 m_idDelegate;
	
	// Run loop can be stopped using this flag
	@private 
	BOOL			m_bStopRequested;
	BOOL			m_bActualStopState;
    BOOL    pause_;
	
	double			m_dPrevTime;
}

@property (assign, getter=delegate, setter=delegate:) id <TMRunLoopDelegate> m_idDelegate;

// This is where each frame is being processed. must be called on Main thread
- (void) processFrame;

// Display Link method
- (void) displayLink:(CADisplayLink*)sender;

// Call this method to run the runloop
- (void) run;

// Request a stop of the looping
- (void) stop;
- (BOOL) isStopped;

- (void) pause;
- (void) resume;

// The next routine is used to add renderables or logic updaters to the corresponding array
- (void) pushBackChild:(NSObject*)inChild;
- (void) pushChild:(NSObject*)inChild;
- (void) removeObject:(NSObject*) obj;
- (void) removeAllObjects;
- (void) removeCommandsForObject:(NSObject*) obj;

@end
