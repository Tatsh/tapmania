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

#import "AbstractRenderer.h"

@class SongPickerMenuItem, TogglerItem;

#define kNumWheelItems 9
#define kNumSwipePositions 10

@interface SongPickerMenuRenderer : AbstractRenderer <TMLogicUpdater, TMTransitionSupport, TMGameUIResponder> {
	TogglerItem*			m_pSpeedToggler;
	
	NSMutableArray*			m_pWheelItems;		// Always maintain 9 wheel items
	int						m_nCurrentSongId;	// Selected song index
	
	float					m_fVelocity;		// Current speed of the wheel
	float					m_fAcceleration;	// The acceleration (breaks system)
	
	int						m_nCurrentSwipePosition;
	float					m_fSwipeBuffer[kNumSwipePositions];
	float					m_fLastSwipeY;
	float					m_fSwipeDirection;	// -1 or +1
	
	BOOL					m_bStartSongPlay;
}

@end
