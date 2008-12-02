//
//  BasicTransition.m
//  TapMania
//
//  Created by Alex Kremer on 02.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "BasicTransition.h"
#import "RenderEngine.h"
#import "LogicEngine.h"

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
	
	// Remove the current screen from rendering/logic runloops.
	[[LogicEngine sharedInstance] clearLogicUpdaters];	
	[[RenderEngine sharedInstance] clearRenderers];
	 
	// Drop current screen (might add some fadeout or so here)
	[[LogicEngine sharedInstance] releaseCurrentScreen];
	
	// Set new one and show it
	[[LogicEngine sharedInstance] setCurrentScreen:to];
	[[RenderEngine sharedInstance] registerRenderer:to withPriority:kRunLoopPriority_Highest];
	 
	// Add to logic updating runloop only if the screen requires that
	if([to conformsToProtocol:@protocol(TMLogicUpdater)]) {
		[[LogicEngine sharedInstance] registerLogicUpdater:to withPriority:kRunLoopPriority_Highest];
	}
}

@end
