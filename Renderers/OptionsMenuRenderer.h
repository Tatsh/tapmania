//
//  OptionsMenuRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMScreen.h"

@class MenuItem, Slider, TogglerItem;

@interface OptionsMenuRenderer : TMScreen {
	TogglerItem*		m_pThemeToggler, *m_pNoteSkinToggler, *m_pFingerTrackToggler, *m_pVisPadToggler;
	Slider*				m_pSoundSlider;
	MenuItem*			m_pBackButton;
	
	/* Metrics and such */
	CGRect mt_NoteSkinLabel, mt_NoteSkinToggler;
	CGRect mt_ThemeLabel, mt_ThemeToggler;
	CGRect mt_SoundLabel, mt_SoundSlider;
	CGRect mt_FingerTrackingLabel, mt_VisiblePadLabel;
	CGRect mt_FingerTrackingToggler, mt_VisiblePadToggler;
	
	Texture2D *t_BG;
}

@end
