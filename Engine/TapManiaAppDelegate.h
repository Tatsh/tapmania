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

@class EAGLView;
@class AbstractRenderer;

// CONSTANTS
#define kFontName					@"Arial"
#define kStatusFontSize				24

typedef enum {
	kState_StandBy = 0,		// Menu or entrance screen
	kState_Play,			// When you play a song
	kState_Success,			// When you successfully cleared a song
	kState_Failure			// When you failed a song
} State;

typedef struct
{
	GLfloat			x;
	GLfloat			y;
} Vector2D;


@interface TapManiaAppDelegate : NSObject <UIApplicationDelegate, JoyPadControllerDelegate, TMRunLoopDelegate>
{
	TMRunLoop		* logicLoop;
	
	State					_state;
	CFTimeInterval			_lastTime;
	
	JoyPad*					joyPad;  // The joypad
}

// Window
@property (retain, nonatomic, readonly) JoyPad* joyPad;

- (void) showJoyPad;
- (void) hideJoyPad;	

@end

