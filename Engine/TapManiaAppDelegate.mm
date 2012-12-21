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
#import "TDBSearch.h"
#import "JoyPad.h"

#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioFile.h>
#import <AVFoundation/AVFoundation.h>

//#import "FlurryAPI.h"

@implementation TapManiaAppDelegate

@synthesize window = m_pWindow;
@synthesize rootView = m_pRootView;
@synthesize rootController = m_pRootCtrl;
@synthesize tapdb;

void uncaughtExceptionHandler(NSException *exception)
{
//    [FlurryAPI logError:@"Uncaught" message:@"Crash!" exception:exception];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

    [UIApplication sharedApplication].idleTimerDisabled = YES;

    // Enable audio
    OSStatus result = AudioSessionInitialize(NULL, NULL, NULL, NULL);
    if (result)
    {
        TMLog(@"Problems initializing audio session.");
    }

    UInt32 sessionCategory = kAudioSessionCategory_SoloAmbientSound;
    result = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof (sessionCategory), &sessionCategory);
    if (result)
    {
        TMLog(@"Problems setting category for audio session.");
    }

    result = AudioSessionSetActive(true);
    if (result)
    {
        TMLog(@"Problems activating audio session.");
    }

    // Get rid of the accelerometer
    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:1000.0f];

    // Start analytics (flurry)
//	[FlurryAPI startSession:@"8BN9QAWK22Q2RA38DTUC"];

    // Show window
    [self.window makeKeyAndVisible];

    // Configure iCade support
    iCadeReaderView *control = [[iCadeReaderView alloc] initWithFrame:CGRectZero];
    [self.window addSubview:control];
    control.active = YES;
    control.delegate = self;
    [control release];

    // Start the game.
    [[TapMania sharedInstance] performSelector:@selector(startGame)
                                      onThread:[NSThread currentThread] withObject:nil waitUntilDone:NO];

    // Return as soon as possible
    TMLog(@"Returning from app delegate");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[TapMania sharedInstance] resume];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[TapMania sharedInstance] pause];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    BROADCAST_MESSAGE(kApplicationShouldTerminateMessage, nil);
}

// iCade support
- (void)buttonDown:(iCadeState)button
{
    TMLog(@"Got button press %d", button);

    switch (button)
    {
        case iCadeButtonG: // select
            [[TapMania sharedInstance].joyPad setState:YES forButton:kJoyButtonExit];
            break;
        case iCadeButtonF:
        case iCadeJoystickUp:
            [[TapMania sharedInstance].joyPad setState:YES forButton:kJoyButtonUp];
            break;
        case iCadeButtonB:
        case iCadeJoystickLeft:
            [[TapMania sharedInstance].joyPad setState:YES forButton:kJoyButtonLeft];
            break;
        case iCadeButtonH:
        case iCadeJoystickRight:
            [[TapMania sharedInstance].joyPad setState:YES forButton:kJoyButtonRight];
            break;
        case iCadeButtonD:
        case iCadeJoystickDown:
            [[TapMania sharedInstance].joyPad setState:YES forButton:kJoyButtonDown];
            break;
        default:
            break;
    }
}

- (void)buttonUp:(iCadeState)button
{
    TMLog(@"Got button release %d", button);

    switch (button)
    {
        case iCadeButtonG: // select
            [[TapMania sharedInstance].joyPad setState:NO forButton:kJoyButtonExit];
            break;
        case iCadeButtonF:
        case iCadeJoystickUp:
            [[TapMania sharedInstance].joyPad setState:NO forButton:kJoyButtonUp];
            break;
        case iCadeButtonB:
        case iCadeJoystickLeft:
            [[TapMania sharedInstance].joyPad setState:NO forButton:kJoyButtonLeft];
            break;
        case iCadeButtonH:
        case iCadeJoystickRight:
            [[TapMania sharedInstance].joyPad setState:NO forButton:kJoyButtonRight];
            break;
        case iCadeButtonD:
        case iCadeJoystickDown:
            [[TapMania sharedInstance].joyPad setState:NO forButton:kJoyButtonDown];
            break;
        default:
            break;

    }

}


@end
