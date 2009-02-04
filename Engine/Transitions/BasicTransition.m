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
	
	m_pFrom = fromScreen;
	m_pTo = toScreen;
	
	return self;
}

- (void) action:(NSNumber*)fDelta {
	NSLog(@"Transition requested...");
	
	// Remove the current screen from rendering/logic runloop.
	[[TapMania sharedInstance] deregisterAll];	
	
	// Do custom deinitialization for transition if the object supports it
	if([m_pFrom conformsToProtocol:@protocol(TMTransitionSupport)]){
		[m_pFrom performSelector:@selector(deinitOnTransition)];
	}	
	
	// Drop current screen (might add some fadeout or so here)
	[[TapMania sharedInstance] releaseCurrentScreen];
	
	// Do custom initialization for transition if the object supports it
	if([m_pTo conformsToProtocol:@protocol(TMTransitionSupport)]){
		[m_pTo performSelector:@selector(setupForTransition)];
	}
	
	// Set new one and show it
	[[TapMania sharedInstance] setCurrentScreen:m_pTo];
	[[TapMania sharedInstance] registerObject:m_pTo withPriority:kRunLoopPriority_Highest];
}

@end
