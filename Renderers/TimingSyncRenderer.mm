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
#import "MenuItem.h"
#import "TapMania.h"
#import "Label.h"
#import "SettingsEngine.h"
#import "MenuItem.h"
#import "FontString.h"

extern TMGameState *g_pGameState;

@interface TimingSyncRenderer ()
- (void)resetButtonHit;

@end

@implementation TimingSyncRenderer

- (id)initWithMetrics:(NSString *)inMetrics
{
    g_pGameState->m_pSong = [[SongsDirectoryCache sharedInstance] getSyncSong];
    g_pGameState->m_nSelectedDifficulty = kSongDifficulty_Beginner;

    self = [super initWithMetrics:@"SongPlay"];
    if (!self)
        return nil;

    m_pResetButton = [[MenuItem alloc] initWithMetrics:@"TimingSync ResetButtonCustom"];
    [m_pResetButton setActionHandler:@selector(resetButtonHit) receiver:self];

    m_pOffsetLabel = [[FontString alloc] initWithFont:@"TimingSync CurrentOffset" andText:@"Current offset:"];
    mt_OffsetLabelLocation = POINT_METRIC(@"TimingSync CurrentOffset");

    [m_pOffsetLabel setAlignment:UITextAlignmentCenter];
    
    return self;
}

- (void)resetButtonHit
{
    g_pGameState->m_dGlobalOffset = 0.0;
}

- (void)dealloc
{
    [m_pOffsetLabel release];
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

    // Add controls
    [self pushBackControl:m_pResetButton];
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

- (void)update:(float)fDelta
{
    [super update:fDelta];

    if (g_pGameState->m_bPlayingGame)
    {
        [m_pOffsetLabel updateText:[NSString stringWithFormat:@"Current offset: %.4f", g_pGameState->m_dGlobalOffset]];
    }
}


- (void)render:(float)fDelta
{
    [super render:fDelta];

    // now render the current offset string
    if (g_pGameState->m_bPlayingGame)
    {
        [m_pOffsetLabel drawAtPoint:mt_OffsetLabelLocation];
    }
}


@end
