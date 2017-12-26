//
//  $Id$
//  CreditsRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "CreditsRenderer.h"
#import "Texture2D.h"
#import "InputEngine.h"
#import "ThemeManager.h"

#import "EAGLView.h"
#import "TapMania.h"
#import "MainMenuRenderer.h"
#import "MenuItem.h"
#import "TMSoundEngine.h"

@implementation CreditsRenderer

/* TMTransitionSupport methods */
- (void)setupForTransition
{
    [super setupForTransition];

    // We will show the credits until this set to YES
    m_bShouldReturn = NO;

    [[TMSoundEngine sharedInstance] stopMusic];
    [[TMSoundEngine sharedInstance] addToQueue:SOUND(@"Credits Music")];
    [[TapMania sharedInstance] toggleAds:NO];
}

- (void)deinitOnTransition
{
    [super deinitOnTransition];

    [[TMSoundEngine sharedInstance] stopMusic];
    [[TapMania sharedInstance] toggleAds:YES];
}


/* TMLogicUpdater method */
- (void)update:(float)fDelta
{
    [super update:fDelta];

    /* Check whether we should leave the credits screen already */
    if (m_bShouldReturn)
    {
        // Back to main menu
        [[TapMania sharedInstance] switchToScreen:[MainMenuRenderer class] withMetrics:@"MainMenu"];
        m_bShouldReturn = NO; // To be sure we not do the transition more than once
    }
}

/* TMGameUIResponder methods */
- (BOOL)tmTouchesEnded:(const TMTouchesVec&)touches withEvent:(UIEvent *)event
{
    m_bShouldReturn = YES;

    return YES;
}

@end
