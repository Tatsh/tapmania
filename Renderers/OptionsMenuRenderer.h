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
	TogglerItem*		m_pThemeToggler, *m_pNoteSkinToggler;
	
	/* Metrics and such */
	CGRect mt_NoteSkinToggler;
	CGRect mt_ThemeToggler;
}

@end
