//
//  SongPickerMenuRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 07.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InputEngine.h"
#import "TMLogicUpdater.h"
#import "TMTransitionSupport.h"
#import "TMGameUIResponder.h"

#import "SongPickerMenuItem.h"
#import "AbstractRenderer.h"
#import "TogglerItem.h"

#define kNumWheelItems 7

@interface SongPickerMenuRenderer : AbstractRenderer <TMLogicUpdater, TMTransitionSupport, TMGameUIResponder> {
	TogglerItem*			m_pSpeedToggler;
	
	SongPickerMenuItem*		m_pWheelItems[kNumWheelItems]; // Always 7 wheel items are visible on screen
	int						m_nCurrentSongId;	// Selected song index
	
	float					m_fScrollVelocity;	// Current velocity of the wheel scroll if moving. -values is down, +values is up
	float					m_fMoveRows;
	
	CGPoint					m_oStartTouchPos, m_oLastTouchPos;
	float					m_fStartTouchTime, m_fLastMoveTime;
	
	BOOL					m_bStartSongPlay;
}

@end
