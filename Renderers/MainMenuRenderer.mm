//
//  $Id$
//  MainMenuRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "MainMenuRenderer.h"
#import "MenuItem.h"
#import "Label.h"
#import "ImageButton.h"

#import "TMRunLoop.h"
#import "TMRenderable.h"

#import "EAGLView.h"
#import "InputEngine.h"
#import "TapMania.h"
#import "ThemeManager.h"
#import "Texture2D.h"
#import "SongsDirectoryCache.h"

#import "ZoomEffect.h"

#import "FontManager.h"
#import "Font.h"
#import "Quad.h"

#import "TMSoundEngine.h"
#import "TMSound.h"

#import "GameState.h"
#import "VersionInfo.h"
#import "DisplayUtil.h"

extern TMGameState *g_pGameState;

@interface MainMenuRenderer ()
@end


@implementation MainMenuRenderer
{
    CGRect mt_LikeButton;
}

/* TMTransitionSupport methods */
- (void)setupForTransition
{
    [super setupForTransition];

    // sounds
    sr_BG = SOUND(@"MainMenu Music");

    // Create version and copyright
    Label *version = [[Label alloc] initWithMetrics:@"MainMenu Version"];
    [version setName:TAPMANIA_VERSION_STRING];
    [self pushBackChild:version];

    // Play music
    if (!sr_BG.playing)
    {
        [[TMSoundEngine sharedInstance] addToQueue:sr_BG];
    }

    // Get ads back to place
    [[TapMania sharedInstance] toggleAds:YES];

    // Enable/disable play button
    if ([SongsDirectoryCache sharedInstance].catalogueIsEmpty)
    {
        MenuItem *playButton = (MenuItem *) [self findControl:@"MainMenu PlayButton"];
        if (playButton != nil)
        {
            [playButton disable];
            [playButton setName:@"No Songs"];
        }
    }

    g_pGameState->m_bPlayingGame = NO;
}

- (void)beforeTransition
{
    [[InputEngine sharedInstance] disableDispatcher];
}

/* TMRenderable method */
- (void)render:(float)fDelta
{
    // Draw children and bg
    [super render:fDelta];
}

@end
