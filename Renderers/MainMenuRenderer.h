//
//  $Id$
//  MainMenuRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMScreen.h"
#import "FBConnect.h"
#import "FacebookLikeView.h"

@class MenuItem, TMSound, Texture2D, Quad;

@interface MainMenuRenderer : TMScreen
{
    /* Metrics and such */
    TMSound *sr_BG;
    
    Facebook *_facebook;
}

@property (nonatomic, retain) FacebookLikeView *facebookLikeView;

@end
