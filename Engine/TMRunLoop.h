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
#import "TMObjectWithPriority.h"
#import "TMMessageSupport.h"

#ifdef __cplusplus

#include <vector>
using namespace std;

typedef vector<TMObjectWithPriority*> TMObjList;

#endif

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
}

@property (assign, getter=delegate, setter=delegate:) id <TMRunLoopDelegate> m_idDelegate;


// Call this method to run the runloop
- (void) run;

// Request a stop of the looping
- (void) stop;
- (BOOL) isStopped;

// The next routine is used to add renderables or logic updaters to the corresponding array
- (void) registerObject:(NSObject*) obj withPriority:(TMRunLoopPriority) priority;
- (void) deregisterObject:(NSObject*) obj;
- (void) deregisterAllObjects;

@end
