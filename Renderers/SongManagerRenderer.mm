//
//  $Id$
//  SongManagerRenderer.m
//
//  Created by Alex Kremer on 06.08.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "SongManagerRenderer.h"

#import "Texture2D.h"

#import "InputEngine.h"
#import "TapMania.h"
#import "ThemeManager.h"
#import "EAGLView.h"
#import "WebServer.h"

#import "QuadTransition.h"
#import "OptionsMenuRenderer.h"

//#import "FlurryAPI.h"

@implementation SongManagerRenderer

/* TMTransitionSupport methods */
- (void)setupForTransition
{
    [super setupForTransition];
//	[FlurryAPI logEvent:@"songman_screen_enter"];

    mt_UrlPosition = POINT_METRIC(@"SongManager Url");

    // Start with no action
    m_nAction = kSongManagerAction_None;

    // Now start the web server
    [[WebServer sharedInstance] start];

    m_pServerUrl = [[Texture2D alloc] initWithString:[WebServer sharedInstance].m_sCurrentServerURL
                                          dimensions:CGSizeMake(320, 60) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:18];

    m_nAction = kSongManagerAction_Running;
}

- (void)deinitOnTransition
{
    [super deinitOnTransition];

    // Stop web server
    [[WebServer sharedInstance] stop];
}

- (void)dealloc
{
    [m_pServerUrl release];

    [super dealloc];
}

/* TMRenderable methods */
- (void)render:(float)fDelta
{
    // Render kids and bg
    [super render:fDelta];

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    [m_pServerUrl drawAtPoint:mt_UrlPosition];

    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_BLEND);
}

/* TMLogicUpdater method */
- (void)update:(float)fDelta
{
    [super update:fDelta];

    if (m_nAction == kSongManagerAction_Exit)
    {
        // Exit to options menu
        [[TapMania sharedInstance] switchToScreen:[OptionsMenuRenderer class] withMetrics:@"OptionsMenu" usingTransition:[QuadTransition class]];

        m_nAction = kSongManagerAction_None;
    }
}

/* TMGameUIResponder methods */
- (BOOL)tmTouchesEnded:(const TMTouchesVec&)touches withEvent:(UIEvent *)event
{
    if (touches.size() == 1 && m_nAction != kSongManagerAction_None)
    {
        // Exit
        m_nAction = kSongManagerAction_Exit;
    }

    return YES;
}

@end