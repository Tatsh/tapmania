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

@class TMRunLoop, ReceptorRow, LifeBar;

typedef enum {
	kPadConfigAction_None = 0,
	kPadConfigAction_SelectedTrack,
	kPadConfigAction_SelectLocation,
	kPadConfigAction_SelectedLocation,
	kNumPadConfigActions
} TMPadConfigActions;

@interface PadConfigRenderer : NSObject <TMLogicUpdater, TMRenderable, TMTransitionSupport, TMGameUIResponder> {
	CGRect m_oReceptorButtons[kNumOfAvailableTracks];

	ReceptorRow*			m_pReceptorRow;
	LifeBar*				m_pLifeBar;
	
	TMPadConfigActions		m_nPadConfigAction;
	TMAvailableTracks		m_nSelectedTrack;
}

@end
