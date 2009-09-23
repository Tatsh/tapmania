//
//  SongPickerMenuRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 07.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMScreen.h"

@class SongPickerWheel, TMSound, TogglerItem, MenuItem, Texture2D;

@interface SongPickerMenuRenderer : TMScreen {
	SongPickerWheel*		m_pSongWheel;
	TogglerItem*			m_pSpeedToggler;
	TogglerItem*			m_pDifficultyToggler;
	MenuItem*				m_pBackMenuItem;
	TMSound*				m_pPreviewMusic;
	
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
