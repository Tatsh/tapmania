//
//  TapManiaAppDelegate.m
//  TapMania
//  This class is based on the example source code in CrashLanding.
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright Godexsoft 2008. All rights reserved.
//

#import "TapManiaAppDelegate.h"

#define kListenerDistance			1.0  // Used for creating a realistic sound field

@implementation TapManiaAppDelegate

- (void) applicationDidFinishLaunching:(UIApplication*)application {
	//Setup the game
	_state = kState_StandBy;
					
	[UIApplication sharedApplication].idleTimerDisabled = YES;	

	// Get rid of the accelerometer
	[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:1000.0f];                                                                                                                                                               
	
	// Start the game.
	[[TapMania sharedInstance] startGame];
}

@end
