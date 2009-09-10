//
//  SongPickerMenuRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 07.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMLogicUpdater.h"
#import "TMTransitionSupport.h"
#import "TMGameUIResponder.h"
#import "TMRenderable.h"

@class SongPickerMenuItem, TMSound, TogglerItem, BasicEffect, MenuItem;

#define kNumWheelItems 10
#define kNumSwipePositions 10

#define kSelectedWheelItemId 4

#define kWheelStaticFriction	0.25f
#define kWheelMass				80.0f

@interface SongPickerMenuRenderer : NSObject <TMRenderable, TMLogicUpdater, TMTransitionSupport, TMGameUIResponder> {
	BasicEffect*			m_pSpeedToggler;
	BasicEffect*			m_pDifficultyToggler;
	MenuItem*				m_pBackMenuItem;
	TMSound*				m_pPreviewMusic;
	
	NSMutableArray*			m_pWheelItems;		// The wheel items
	int						m_nCurrentSongId;	// Selected song index
	
	float					m_fVelocity;		// Current speed of the wheel
	
	int						m_nCurrentSwipePosition;
	float					m_fSwipeBuffer[kNumSwipePositions][2]; // 0=delta time, 1=delta y
	float					m_fLastSwipeY;
	double					m_dLastSwipeTime;
	
	BOOL					m_bStartSongPlay;
}

@end
