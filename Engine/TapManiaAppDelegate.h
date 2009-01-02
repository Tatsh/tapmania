//
//  TapManiaAppDelegate.h
//  TapMania
//  This class is based on the example source code in CrashLanding.
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright Godexsoft 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapMania.h"

typedef enum {
	kState_StandBy = 0,		// Menu or entrance screen
	kState_Play,			// When you play a song
	kState_Success,			// When you successfully cleared a song
	kState_Failure			// When you failed a song
} State;

@interface TapManiaAppDelegate : NSObject <UIApplicationDelegate>
{
	State					_state;
}

@end

