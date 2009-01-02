//
//  BasicTransition.m
//  TapMania
//
//  Created by Alex Kremer on 02.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "BasicTransition.h"
#import "TMTransitionSupport.h"
#import "TapMania.h"

@implementation BasicTransition

- (id) initFromScreen:(AbstractRenderer*)fromScreen toScreen:(AbstractRenderer*)toScreen {
	self = [super init];
	if (!self)
		return nil;
	
	from = fromScreen;
	to = toScreen;
	
	return self;
}

- (void) action:(NSNumber*)fDelta {
	NSLog(@"Transition requested...");
	
	// Remove the current screen from rendering/logic runloop.
	[[TapMania sharedInstance] deregisterAll];	
	
	// Do custom deinitialization for transition if the object supports it
	if([from conformsToProtocol:@protocol(TMTransitionSupport)]){
		[from performSelector:@selector(deinitOnTransition)];
	}	
	
	// Drop current screen (might add some fadeout or so here)
	[[TapMania sharedInstance] releaseCurrentScreen];
	
	// Do custom initialization for transition if the object supports it
	if([to conformsToProtocol:@protocol(TMTransitionSupport)]){
		[to performSelector:@selector(setupForTransition)];
	}
	
	// Set new one and show it
	[[TapMania sharedInstance] setCurrentScreen:to];
	[[TapMania sharedInstance] registerObject:to withPriority:kRunLoopPriority_Highest];
}

@end
