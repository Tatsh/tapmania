//
//  LogicEngine.h
//  TapMania
//
//  Created by Alex Kremer on 01.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMSong.h"
#import "TMSongOptions.h"

#import "TMRunLoop.h"
#import "AbstractRenderer.h"

#import "TMSingleTimeTask.h"

@interface LogicEngine : NSObject <TMRunLoopDelegate> {
	TMRunLoop		*logicRunLoop;
	// The lock for logicRunLoop is taken from the renderEngine
	
	TMSong* currentSong;	// Points to currently selected song which can be played
	TMSongOptions* currentSongOptions;	// Holds current song options which are applied to the currentSong
	
	AbstractRenderer* currentScreen;	// This is set to currently rendering screen
}

// Go to another screen using this method
// This method will remove current screen and release memory. Afterwards it will switch to the specified screen.
- (void) switchToScreen:(AbstractRenderer*)screenRenderer;

- (void) registerLogicUpdater:(NSObject*) logicUpdater withPriority:(TMRunLoopPriority) priority;
- (void) clearLogicUpdaters;

- (void) setCurrentScreen:(AbstractRenderer*) screenRenderer;
- (void) releaseCurrentScreen;

+ (LogicEngine *)sharedInstance;

@end
