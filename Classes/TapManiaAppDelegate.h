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

@class EAGLView;
@class AbstractRenderer;
@protocol SceneRenderer;

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


@interface TapManiaAppDelegate : NSObject <UIApplicationDelegate, JoyPadControllerDelegate>
{
	UIWindow		*window;
	EAGLView		*glView;
	
	NSTimer*				_timer;
	State					_state;
	CFTimeInterval			_lastTime;
	GLfloat					_basePosition;   // Where the arrows match the base
	
	LifeBar*				lifeBar; // The lifebar
	JoyPad*					joyPad;  // The joypad
	
	id						currentRenderer;  // The current scene renderer
}

// Window
@property (retain, nonatomic) UIWindow* window;

// Points to the current scene renderer
@property (assign) id <SceneRenderer> currentRenderer;

- (void) showJoyPad;
- (void) hideJoyPad;	

- (void) activateRenderer:(AbstractRenderer*) renderer noSceneRendering:(BOOL) noSceneRendering;
- (void) deactivateRendering;

@end

