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

#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioFile.h>
#import <AVFoundation/AVFoundation.h>

#import "FlurryAPI.h"

@implementation TapManiaAppDelegate

@synthesize window = m_pWindow;
@synthesize rootView = m_pRootView;
@synthesize rootController = m_pRootCtrl;

void uncaughtExceptionHandler(NSException *exception) {
    [FlurryAPI logError:@"Uncaught" message:@"Crash!" exception:exception];
}

- (void) applicationDidFinishLaunching:(UIApplication*)application {				
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	
	[UIApplication sharedApplication].idleTimerDisabled = YES;	
	
	// Enable audio
	OSStatus result = AudioSessionInitialize(NULL, NULL, NULL, NULL);
	if(result) {
		TMLog(@"Problems initializing audio session.");
	}
		
	UInt32 sessionCategory = kAudioSessionCategory_SoloAmbientSound;
	result = AudioSessionSetProperty (kAudioSessionProperty_AudioCategory, sizeof (sessionCategory), &sessionCategory);
	if(result) {
		TMLog(@"Problems setting category for audio session.");
	}
	
	result = AudioSessionSetActive (true);
	if(result) {
		TMLog(@"Problems activating audio session.");
	}
	
	// Get rid of the accelerometer
	[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:1000.0f];                                                                                                                                                               
	
	// Start analytics (flurry)
	[FlurryAPI startSession:@"8BN9QAWK22Q2RA38DTUC"];
	
	// Show window
	[self.window makeKeyAndVisible];
	
	// Start the game.
	[[TapMania sharedInstance] startGame];
}

- (void) applicationWillTerminate:(UIApplication *)application {
	BROADCAST_MESSAGE(kApplicationShouldTerminateMessage, nil);
}

@end
