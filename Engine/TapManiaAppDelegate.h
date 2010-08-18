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
@class TDBSearchController;

@interface TapManiaAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow* m_pWindow;
	UIView* m_pRootView;
	UIViewController* m_pRootCtrl;
	TDBSearchController* tapdb;
}

@property (retain, nonatomic) IBOutlet TDBSearchController* tapdb;
@property (retain, nonatomic) IBOutlet UIWindow* window;
@property (retain, nonatomic) IBOutlet UIView* rootView;

@property (retain, nonatomic) IBOutlet UIViewController* rootController;

@end

