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
#import "JoyPad.h"
#import "DisplayUtil.h"

#import <AudioToolbox/AudioToolbox.h>

#import "Flurry.h"


#define kReminderTimeout 60*60*24*3
#define SavedHTTPCookiesKey @"SavedHTTPCookies"


@implementation TapManiaAppDelegate

@synthesize window = m_pWindow;
@synthesize rootView = m_pRootView;
@synthesize rootController = m_pRootCtrl;
@synthesize tapdb;
@synthesize fakeDefaultPng = _fakeDefaultPng;


void uncaughtExceptionHandler(NSException *exception)
{
    [Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
}

- (BOOL)application:(UIApplication *)app didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

    [UIApplication sharedApplication].idleTimerDisabled = YES;

    //Restore cookies
    NSData *cookiesData = [[NSUserDefaults standardUserDefaults] objectForKey:SavedHTTPCookiesKey];
    if ( cookiesData )
    {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesData];
        for ( NSHTTPCookie *cookie in cookies )
        {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }

    // Enable audio
    OSStatus result = AudioSessionInitialize(NULL, NULL, NULL, NULL);
    if ( result )
    {
        TMLog(@"Problems initializing audio session.");
    }

    UInt32 sessionCategory = kAudioSessionCategory_SoloAmbientSound;
    result = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof (sessionCategory), &sessionCategory);
    if ( result )
    {
        TMLog(@"Problems setting category for audio session.");
    }

    result = AudioSessionSetActive(true);
    if ( result )
    {
        TMLog(@"Problems activating audio session.");
    }

    // Get rid of the accelerometer
    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:1000.0f];

    // Start analytics (flurry)
    [Flurry startSession:@"X5MZSGTQ39363RN3798Z"];

    // Add bg

    UIImage *img = [UIImage imageNamed:[DisplayUtil getDefaultPngName]];
    if ( [DisplayUtil isRetina] )
    {
        img = [UIImage imageWithCGImage:img.CGImage scale:2 orientation:img.imageOrientation];
    }

    self.fakeDefaultPng = [[[UIImageView alloc] initWithImage:img] autorelease];
    [self.rootView addSubview:self.fakeDefaultPng];

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

    // In case play reminder fired
    application.applicationIconBadgeNumber = 0;

    // Make sure old one is not active anymore
    [application cancelAllLocalNotifications];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[TapMania sharedInstance] pause];

    // Save cookies
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    [[NSUserDefaults standardUserDefaults] setObject:cookiesData
                                              forKey:SavedHTTPCookiesKey];

    // Reset local-notification reminder
    UILocalNotification *localNotif = [[[UILocalNotification alloc] init] autorelease];
    if ( localNotif == nil )
    {
        return;
    }

    NSDate *reminderDate = [NSDate dateWithTimeIntervalSinceNow:kReminderTimeout];

    localNotif.fireDate = reminderDate;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];

    localNotif.alertBody = [NSString stringWithFormat:@"Fancy a game? ;-)"];
    localNotif.alertAction = @"Play now!";

    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;

    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    BROADCAST_MESSAGE(kApplicationShouldTerminateMessage, nil);
}

// iCade support
- (void)buttonDown:(iCadeState)button
{
    [[TapMania sharedInstance] hardwareControllerButtonDown:button];
}

- (void)buttonUp:(iCadeState)button
{
    [[TapMania sharedInstance] hardwareControllerButtonUp:button];
}


@end
