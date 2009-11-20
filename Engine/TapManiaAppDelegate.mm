//
//  $Id$
//  TapManiaAppDelegate.m
//  TapMania
//  This class is based on the example source code in CrashLanding.
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright Godexsoft 2008. All rights reserved.
//

#import "TapManiaAppDelegate.h"
#import "TapMania.h"
#import "MessageManager.h"
#import "TMMessage.h"

@implementation TapManiaAppDelegate

- (void) applicationDidFinishLaunching:(UIApplication*)application {				
	[UIApplication sharedApplication].idleTimerDisabled = YES;	

	// Get rid of the accelerometer
	[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:1000.0f];                                                                                                                                                               
	
	// Start the game.
	[[TapMania sharedInstance] startGame];
}

- (void) applicationWillTerminate:(UIApplication *)application {
	BROADCAST_MESSAGE(kApplicationShouldTerminateMessage, nil);
}

@end
