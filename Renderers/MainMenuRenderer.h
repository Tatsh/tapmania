//
//  MainMenuRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMLogicUpdater.h"
#import "TMRenderable.h"
#import "TMTransitionSupport.h"
#import "TMGameUIResponder.h"

@class MenuItem, Vector;

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

@interface MainMenuRenderer : NSObject <TMLogicUpdater, TMRenderable, TMTransitionSupport, TMGameUIResponder> {
	MainMenuItem	m_nSelectedMenu;
	MainMenuState	m_nState;
	float			m_fAnimationTime;
	
	Vector*			m_pVelocity[kNumMainMenuItems];
	MenuItem*		m_pMainMenuItems[kNumMainMenuItems];
}

@end
