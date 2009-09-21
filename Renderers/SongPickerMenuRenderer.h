//
//  SongPickerMenuRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 07.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMScreen.h"

@class SongPickerMenuItem, TMSound, TogglerItem, BasicEffect, MenuItem, Texture2D;

#define kNumWheelItems 10
#define kNumSwipePositions 10

#define kSelectedWheelItemId 4

#define kWheelStaticFriction	0.25f
#define kWheelMass				80.0f

@interface SongPickerMenuRenderer : TMScreen {
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
	
	/* Metrics and such */
	CGRect mt_SpeedToggler, mt_DifficultyToggler, mt_ModPanel;
	CGRect mt_ItemSong;
	int mt_ItemSongHalfHeight;
	
	CGRect mt_HighlightCenter;
	CGRect mt_Highlight;
	int mt_HighlightHalfHeight;
	
	Texture2D* t_SongPickerBG;
	Texture2D* t_Highlight;
	Texture2D* t_ModPanel;
	
	TMSound* sr_SelectSong;	
}

@end
