//
//  $Id$
//  SongManagerRenderer.m
//
//  Created by Alex Kremer on 06.08.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "SongManagerRenderer.h"

#import "TapMania.h"
#import "WebServer.h"

#import "QuadTransition.h"
#import "OptionsMenuRenderer.h"
#import "TMControl.h"
#import "Label.h"

//#import "FlurryAPI.h"

@implementation SongManagerRenderer

/* TMTransitionSupport methods */
- (void)setupForTransition
{
    [super setupForTransition];
//	[FlurryAPI logEvent:@"songman_screen_enter"];

    // Start with no action
    m_nAction = kSongManagerAction_None;

    // Now start the web server
    [[WebServer sharedInstance] start];

    m_nAction = kSongManagerAction_Running;

    // Set the label
    [(Label*)[self findControl:@"SongManager UrlLabel"] setName:[WebServer sharedInstance].m_sCurrentServerURL];
}

- (void)deinitOnTransition
{
    [super deinitOnTransition];

    // Stop web server
    [[WebServer sharedInstance] stop];
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