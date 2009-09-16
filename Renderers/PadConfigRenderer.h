//
//  PadConfigRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 6/16/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMScreen.h"
#import "TMGameUIResponder.h"

#import "TMSteps.h"

@class TMRunLoop, ReceptorRow, LifeBar, MenuItem, Vector, Texture2D, TapNote;

typedef enum {
	kPadConfigAction_None = 0,
	kPadConfigAction_SelectedTrack,
	kPadConfigAction_SelectLocation,
	kPadConfigAction_SelectedLocation,
	kPadConfigAction_Reset,
	kPadConfigAction_Exit,
	kNumPadConfigActions
} TMPadConfigActions;

@interface PadConfigRenderer : TMScreen <TMGameUIResponder> {
	Vector*					m_pFingerTap;
	
	ReceptorRow*			m_pReceptorRow;
	LifeBar*				m_pLifeBar;
	MenuItem*				m_pResetButton;
	
	TMPadConfigActions		m_nPadConfigAction;
	TMAvailableTracks		m_nSelectedTrack;
	
	/* Metrics and such */
	Texture2D* t_PadConfigBG;
	Texture2D* t_FingerTap;
	
	TapNote* t_TapNote;
	
	CGRect  mt_ReceptorButtons[kNumOfAvailableTracks];
	CGRect	mt_LifeBar, mt_ResetButton;
}

@end
