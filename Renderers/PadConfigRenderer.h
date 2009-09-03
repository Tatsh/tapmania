//
//  PadConfigRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 6/16/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMLogicUpdater.h"
#import "TMRenderable.h"
#import "TMTransitionSupport.h"
#import "TMGameUIResponder.h"

#import "TMSteps.h"

@class TMRunLoop, ReceptorRow, LifeBar, MenuItem, Vector;

typedef enum {
	kPadConfigAction_None = 0,
	kPadConfigAction_SelectedTrack,
	kPadConfigAction_SelectLocation,
	kPadConfigAction_SelectedLocation,
	kPadConfigAction_Reset,
	kPadConfigAction_Exit,
	kNumPadConfigActions
} TMPadConfigActions;

@interface PadConfigRenderer : NSObject <TMLogicUpdater, TMRenderable, TMTransitionSupport, TMGameUIResponder> {
	CGRect					m_oReceptorButtons[kNumOfAvailableTracks];
	Vector*					m_pFingerTap;
	
	ReceptorRow*			m_pReceptorRow;
	LifeBar*				m_pLifeBar;
	MenuItem*				m_pResetButton;
	
	TMPadConfigActions		m_nPadConfigAction;
	TMAvailableTracks		m_nSelectedTrack;
}

@end
