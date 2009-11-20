//
//  $Id$
//  SongPickerWheel.h
//  TapMania
//
//  Created by Alex Kremer on 23.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMControl.h"

#define kNumWheelItems 10
#define kNumSwipePositions 10

#define kSelectedWheelItemId 4

#define kWheelStaticFriction	0.25f
#define kWheelMass				80.0f

@class SongPickerMenuItem, Texture2D;

#ifdef __cplusplus
	#include <deque>
	#include "ObjCPtr.h"
	typedef ObjCPtr<SongPickerMenuItem> TMWheelItemPtr;
	typedef deque<TMWheelItemPtr> TMWheelItems;
#endif

@interface SongPickerWheel : TMControl {
#ifdef __cplusplus
	TMWheelItems*			m_pWheelItems;
#endif	
	
	int						m_nCurrentSongId;	// Selected song index
	
	float					m_fVelocity;		// Current speed of the wheel
	
	int						m_nCurrentSwipePosition;
	float					m_fSwipeBuffer[kNumSwipePositions][2]; // 0=delta time, 1=delta y
	float					m_fLastSwipeY;
	double					m_dLastSwipeTime;	
	
	/* Metrics and such */
	CGRect	mt_ItemSong;
	int		mt_ItemSongHalfHeight;
	
	CGRect	mt_HighlightCenter;
	CGRect	mt_Highlight;
	int		mt_HighlightHalfHeight;
	
	Texture2D* t_Highlight;
}

- (SongPickerMenuItem*) getSelected;

@end
