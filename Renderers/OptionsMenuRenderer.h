//
//  OptionsMenuRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMLogicUpdater.h"
#import "TMRenderable.h"
#import "TMTransitionSupport.h"
#import "TMGameUIResponder.h"

@class MenuItem;
@class Label;

typedef enum {
	kOptionsLabel_SoundMaster = 0,
	kOptionsLabel_Theme,
	kOptionsLabel_NoteSkin,
	kNumOptionsLabels
} OptionsLabels;

typedef enum {
	kOptionsMenuItem_SoundMaster = 0,
	kOptionsMenuItem_Theme,
	kOptionsMenuItem_NoteSkin,	
	kOptionsMenuItem_JoyPad,
	kOptionsMenuItem_SongManager,
	kOptionsMenuItem_Back,
	kNumOptionsMenuItems
} OptionsMenuItem;

typedef enum {
	kOptionsMenuState_AnimatingOut = 0,
	kOptionsMenuState_Ready,
	kOptionsMenuState_Finished,
	kOptionsMenuState_None
} OptionsMenuState;

@interface OptionsMenuRenderer : NSObject <TMLogicUpdater, TMRenderable, TMTransitionSupport, TMGameUIResponder> {
	OptionsMenuItem		m_nSelectedMenu;
	OptionsMenuState	m_nState;
	double				m_dAnimationTime;

	Label*				m_pLabels[kNumOptionsLabels];
	MenuItem*			m_pOptionsMenuItems[kNumOptionsMenuItems];
}

@end
