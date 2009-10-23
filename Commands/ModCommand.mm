//
//  ModCommand.m
//  TapMania
//
//  Created by Alex Kremer on 9/20/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "ModCommand.h"
#import "GameState.h"

extern TMGameState* g_pGameState;

@implementation ModCommand

- (id) initWithArguments:(NSArray*) inArgs andInvocationObject:(NSObject*) inObj {
	self = [super initWithArguments:inArgs andInvocationObject:inObj];
	if(!self)
		return nil;
	
	if([inArgs count] != 1) {
		TMLog(@"Wrong argument count for command 'mod'. abort.");
		return nil;
	}
	
	return self;
}

- (BOOL) invokeOnObject:(NSObject*)inObj {
	
	NSString* mod = [m_aArguments objectAtIndex:0];
	
	// Check modifier type
	if([mod hasSuffix:@"x"]) {
		// Potentially this is a speed modifier (1x, 2x, 3x etc.)
		// try to convert
		double value = [[mod stringByReplacingOccurrencesOfString:@"x" withString:@""] doubleValue];
		if(value > 0.0) {
			// Ok. valid xspeed mod.
			TMLog(@"Speed modifier found. %f x", value);
			
			// Set the requested speed value
			g_pGameState->m_dSpeedModValue = value;
			return YES;
		}
	}
	
	return NO;
}

@end
