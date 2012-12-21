//
//  $Id$
//  OptionsMenuRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMScreen.h"

@class TogglerItem;

@interface OptionsMenuRenderer : TMScreen
{
    TogglerItem *m_pThemeToggler, *m_pNoteSkinToggler;
}

@end
