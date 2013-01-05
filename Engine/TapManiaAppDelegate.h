//
//  $Id$
//  TapManiaAppDelegate.h
//  TapMania
//  This class is based on the example source code in CrashLanding.
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright Godexsoft 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCadeReaderView.h"

@interface TapManiaAppDelegate : NSObject <UIApplicationDelegate, iCadeEventDelegate>
{
    UIWindow *m_pWindow;
    UIView *m_pRootView;
    UIViewController *m_pRootCtrl;
    UITabBarController *tapdb;
}

@property(retain, nonatomic) IBOutlet UITabBarController *tapdb;
@property(retain, nonatomic) IBOutlet UIWindow *window;
@property(retain, nonatomic) IBOutlet UIView *rootView;

@property(retain, nonatomic) IBOutlet UIViewController *rootController;

@property(nonatomic, retain) UIImageView * fakeDefaultPng;

- (void)removeFakeDefaultPng;


@end

