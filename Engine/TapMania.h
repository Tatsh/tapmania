//
//  TapMania.h
//  TapMania
//
//  Created by Alex Kremer on 02.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMRunLoop.h"	// For TMRunLoopPriority etc.

@class TMSong, TMSongOptions, EAGLView, JoyPad, AbstractRenderer;

@interface TapMania : NSObject <TMRunLoopDelegate> {	
	TMSong*				m_pCurrentSong;	// Points to currently selected song which can be played
	TMSongOptions*		m_pCurrentSongOptions;	// Holds current song options which are applied to the currentSong
	
	AbstractRenderer*	m_pCurrentScreen;	// This is set to currently rendering screen
	
	UIWindow*			m_pWindow;
	EAGLView*			m_pGlView;
		
	TMRunLoop*			m_pGameRunLoop;
	JoyPad*				m_pJoyPad;  // The joypad
}

@property (retain, nonatomic, readonly, getter=glView) EAGLView* m_pGlView;
@property (retain, nonatomic, readonly) UIWindow* m_pWindow;

- (void) startGame;

// Go to another screen using this method
// This method will remove current screen and release memory. Afterwards it will switch to the specified screen.
- (void) switchToScreen:(AbstractRenderer*)screenRenderer;

- (void) registerObject:(NSObject*) obj withPriority:(TMRunLoopPriority) priority;
- (void) deregisterObject:(NSObject*) obj;
- (void) deregisterAll;

- (void) setCurrentScreen:(AbstractRenderer*) screenRenderer;
- (void) releaseCurrentScreen;

- (JoyPad*) enableJoyPad;
- (void) disableJoyPad;

+ (TapMania *)sharedInstance;

@end
