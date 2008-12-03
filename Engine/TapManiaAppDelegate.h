//
//  TapManiaAppDelegate.h
//  TapMania
//  This class is based on the example source code in CrashLanding.
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright Godexsoft 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Texture2D.h"
#import "JoyPad.h"
#import "LifeBar.h"
#import "AbstractRenderer.h"
#import "TMRunLoop.h"
#import "RenderEngine.h"
#import "LogicEngine.h"
#import "InputEngine.h"

@class EAGLView;
@class AbstractRenderer;

typedef enum {
	kState_StandBy = 0,		// Menu or entrance screen
	kState_Play,			// When you play a song
	kState_Success,			// When you successfully cleared a song
	kState_Failure			// When you failed a song
} State;

@interface TapManiaAppDelegate : NSObject <UIApplicationDelegate, JoyPadControllerDelegate>
{
	State					_state;
	JoyPad*					joyPad;  // The joypad
}

// Window
@property (retain, nonatomic, readonly) JoyPad* joyPad;

- (void) showJoyPad;
- (void) hideJoyPad;	

@end

