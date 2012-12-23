//
//  $Id$
//  TimingSyncRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 22.12.12.
//  Copyright 2008-2012 Godexsoft. All rights reserved.
//

#import "TimingSyncRenderer.h"
#import "GameState.h"
#import "TMSoundEngine.h"
#import "ThemeManager.h"
#import "TapMania.h"
#import "SettingsEngine.h"

extern TMGameState *g_pGameState;

@implementation TimingSyncRenderer

- (id)initWithMetrics:(NSString *)inMetrics
{
    g_pGameState->m_pSong = [[SongsDirectoryCache sharedInstance] getSyncSong];
    g_pGameState->m_nSelectedDifficulty = kSongDifficulty_Beginner;

    self = [super initWithMetrics:@"SongPlay"];
    if (!self)
        return nil;

    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)setupForTransition
{
    g_pGameState->m_bIsGlobalSync = YES;

    // Stop options menu music
    [[TMSoundEngine sharedInstance] stopMusic];

    // Remove ads for this time
    [[TapMania sharedInstance] toggleAds:NO];

    [super setupForTransition];
}

- (void)deinitOnTransition
{
    TMLog(@"Global timing became %f after sync", g_pGameState->m_dGlobalOffset);
    [[SettingsEngine sharedInstance] setDoubleValue:g_pGameState->m_dGlobalOffset forKey:@"globalSyncOffset"];

    [super deinitOnTransition];

    // Start playing options menu music
    [[TMSoundEngine sharedInstance] addToQueue:SOUND(@"MainMenu Music")];

    // Restore ads
    [[TapMania sharedInstance] toggleAds:YES];

    // finished
    g_pGameState->m_bIsGlobalSync = NO;
}


@end
