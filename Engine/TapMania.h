//
//  TapMania.h
//  TapMania
//
//  Created by Alex Kremer on 02.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMRunLoop.h"
#import "AbstractRenderer.h"
#import "JoyPad.h"

#import "EAGLView.h"

#import "TMSingleTimeTask.h"

@class TMSong, TMSongOptions;

@interface TapMania : NSObject <TMRunLoopDelegate> {	
	TMSong* currentSong;	// Points to currently selected song which can be played
	TMSongOptions* currentSongOptions;	// Holds current song options which are applied to the currentSong
	
	AbstractRenderer* currentScreen;	// This is set to currently rendering screen
	
	UIWindow		*window;
	EAGLView		*glView;
		
	TMRunLoop*				gameRunLoop;
	JoyPad*					joyPad;  // The joypad
}

@property (retain, nonatomic) EAGLView* glView;
@property (retain, nonatomic) UIWindow* window;

- (void) startGame;

// Go to another screen using this method
// This method will remove current screen and release memory. Afterwards it will switch to the specified screen.
- (void) switchToScreen:(AbstractRenderer*)screenRenderer;

- (void) registerObject:(NSObject*) obj withPriority:(TMRunLoopPriority) priority;
- (void) deregisterAll;

- (void) setCurrentScreen:(AbstractRenderer*) screenRenderer;
- (void) releaseCurrentScreen;

- (JoyPad*) enableJoyPad;
- (void) disableJoyPad;

+ (TapMania *)sharedInstance;

@end
