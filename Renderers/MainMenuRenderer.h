//
//  $Id$
//  MainMenuRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMScreen.h"

@class MenuItem, TMSound, Texture2D, Quad;

@interface MainMenuRenderer : TMScreen
{
    /* Metrics and such */
    Texture2D *t_Donate;
    TMSound *sr_BG;
}

@end
