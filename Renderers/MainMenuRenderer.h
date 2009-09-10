//
//  MainMenuRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMGameUIResponder.h"
#import "TMScreen.h"

@class MenuItem, ImageButton, Label, DialogRenderer;

typedef enum {
	kMainMenuItem_Play = 0,
	kMainMenuItem_Options,
	kMainMenuItem_Credits,
	kNumMainMenuItems
} MainMenuItem;

typedef enum {
	kMainMenuState_AnimatingOut = 0,
	kMainMenuState_Ready,
	kMainMenuState_Finished,
	kMainMenuState_None
} MainMenuState;

@interface MainMenuRenderer : TMScreen <TMGameUIResponder> {
	MainMenuItem	m_nSelectedMenu;
	MainMenuState	m_nState;
	double			m_dAnimationTime;
	
	DialogRenderer* m_pDialog;
	
	MenuItem*		m_pPlayButton, *m_pOptionsButton, *m_pCreditsButton;
}

@end
