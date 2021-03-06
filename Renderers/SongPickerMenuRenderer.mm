//
//  $Id$
//  SongPickerMenuRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 07.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "SongPickerMenuRenderer.h"
#import "TMSong.h"
#import "TimingUtil.h"

#import "TMSoundEngine.h"
#import "TMLoopedSound.h"

#import "SongPickerWheel.h"
#import "TogglerItem.h"
#import "ImageButton.h"

#import "TapMania.h"
#import "ThemeManager.h"
#import "SettingsEngine.h"

#import "GameState.h"

#import "GLUtil.h"
#import "SongPickerMenuItem.h"
#import "BpmDisplay.h"
#import "CDTitleDisplay.h"

extern TMGameState *g_pGameState;

@interface SongPickerMenuRenderer (Private)

- (void)backButtonHit;

- (void)difficultyChanged;

- (void)songSelectionChanged;

- (void)songShouldStart;

@end

@interface SongPickerMenuRenderer ()
- (void)startPreviewMusic;

- (void)changeSong;


@end

@implementation SongPickerMenuRenderer
{
    Texture2D *t_NoBanner;
    CDTitleDisplay *m_pCDTitleDisplay;
}
@synthesize m_previewMusicTimer = _m_previewMusicTimer;
@synthesize m_selectionTimer = _m_selectionTimer;


/* TMTransitionSupport methods */
- (void)setupForTransition
{
    [super setupForTransition];

    // Stop currently playing music
    [[TMSoundEngine sharedInstance] stopMusic]; // Fading:0.5f];

    // Cache metrics
    mt_ItemSong = RECT_METRIC(@"SongPickerMenu Wheel ItemSong");
    mt_ItemSongHalfHeight = (int) (mt_ItemSong.size.height / 2);

    mt_HighlightCenter = RECT_METRIC(@"SongPickerMenu Wheel Highlight");
    mt_Highlight.size = mt_HighlightCenter.size;

    mt_Highlight.origin.x = mt_HighlightCenter.origin.x - mt_Highlight.size.width / 2;
    mt_Highlight.origin.y = mt_HighlightCenter.origin.y - mt_Highlight.size.height / 2;
    mt_HighlightHalfHeight = (int) (mt_Highlight.size.height / 2);

    // Cache graphics
    t_NoBanner = TEXTURE(@"SongResults NoBanner");

    // And sounds
    sr_SelectSong = SOUND(@"SongPickerMenu SelectSong");

    // Push the underlay thing above the wheel
    // TODO: fix this as this is a hack! this should go to a special folder called underlays
    // and automatically be under everything (except the wheel which we programmatically add below it)
    ImageButton *topImg = [[ImageButton alloc] initWithMetrics:@"SongPickerMenu TopImgUnderlay"];
    [self pushChild:topImg];

    // Create the wheel
    m_pSongWheel = [[SongPickerWheel alloc] init];
    [m_pSongWheel setActionHandler:@selector(songShouldStart) receiver:self];
    [m_pSongWheel setChangedActionHandler:@selector(songSelectionChanged) receiver:self];
    [m_pSongWheel setMusicPlaybackHandler:@selector(playPreviewMusic) receiver:self];
    [TapMania sharedInstance].iCadeResponder = m_pSongWheel;
    [self pushControl:m_pSongWheel];

    // Difficulty toggler
    m_pDifficultyToggler = [[TogglerItem alloc] initWithMetrics:@"SongPickerMenu DifficultyTogglerCustom"];
    [m_pDifficultyToggler addItem:[NSNumber numberWithInt:0] withTitle:@"No data"];
    [m_pDifficultyToggler setActionHandler:@selector(difficultyChanged) receiver:self];
    [self pushBackControl:m_pDifficultyToggler];

    // Back button action
    MenuItem *backButton = (MenuItem *) [self findControl:@"SongPickerMenu BackButton"];
    if ( backButton != nil )
    {
        [backButton setActionHandler:@selector(backButtonHit) receiver:self];
    }

    // Get the banner control
    m_pBanner = (ImageButton *) [self findControl:@"SongPickerMenu BannerImg"];

    // Setup bpm display
    m_pBpmDisplay = [[BpmDisplay alloc] initWithMetrics:@"SongPickerMenu BpmDisplay"];
    [self pushBackChild:m_pBpmDisplay];

    // Setup the CDTitle spinner
    m_pCDTitleDisplay = [[CDTitleDisplay alloc] initWithMetrics:@"SongPickerMenu CDTitleDisplay"];
    [self pushBackChild:m_pCDTitleDisplay];

    // Select current song (populate difficulty toggler with it's difficulties)
    [self songSelectionChanged];
    [self playPreviewMusic];

    // Get ads back to place if removed
    [[TapMania sharedInstance] toggleAds:YES];
}

- (void)playPreviewMusic
{
    if ( self.m_previewMusicTimer )
    {
        [self.m_previewMusicTimer invalidate];
        self.m_previewMusicTimer = nil;
    }
    self.m_previewMusicTimer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                                target:self
                                                              selector:@selector(startPreviewMusic)
                                                              userInfo:nil repeats:NO];
}

- (void)startPreviewMusic
{
    // Stop current previewMusic if any
    if ( m_pPreviewMusic )
    {
        [[TMSoundEngine sharedInstance] stopMusic];
        [m_pPreviewMusic release];
    }

    TMSong *song = [[m_pSongWheel getSelected] song];

    // Play preview music
    NSString *previewMusicPath = [[[SongsDirectoryCache sharedInstance] getSongsPath:song.m_iSongsPath] stringByAppendingPathComponent:song.m_sMusicFilePath];
    m_pPreviewMusic = [[TMLoopedSound alloc] initWithPath:previewMusicPath atPosition:song.m_fPreviewStart withDuration:song.m_fPreviewDuration];

    // Potentially dangerous
    [[TMSoundEngine sharedInstance] addToQueue:m_pPreviewMusic];

    // update highlight flash speed
    [m_pSongWheel setCurrentBps:song.m_fBpm];
}

- (void)deinitOnTransition
{
    [super deinitOnTransition];
    [TapMania sharedInstance].iCadeResponder = nil;

    // Remove ads
    [[TapMania sharedInstance] toggleAds:NO];
}

/* TMRenderable method */
- (void)render:(float)fDelta
{
    // Draw kids and bg
    [super render:fDelta];
}

/* Wheel actions */
- (void)songSelectionChanged
{
    if ( self.m_selectionTimer )
    {
        [self.m_selectionTimer invalidate];
        self.m_selectionTimer = nil;
    }
    self.m_selectionTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                             target:self
                                                           selector:@selector(changeSong)
                                                           userInfo:nil repeats:NO];
}

- (void)changeSong
{
    // Drop the texture bind cache as we are going to switch contexts
    TMBindTexture(0);

    [m_pDifficultyToggler removeAll];

    SongPickerMenuItem *selected = (SongPickerMenuItem *) [[m_pSongWheel getSelected] retain];
    TMSong *song = [selected song];

    TMLog(@"Selected song is %@", song.title);

    // Get the preffered difficulty level
    int prefDiff = [[SettingsEngine sharedInstance] getIntValue:@"prefdiff"];
    int closestDiffAvailable = -1024;

    // Go through all possible difficulties
    for ( int dif = (int) kSongDifficulty_Invalid; dif < kNumSongDifficulties; ++dif )
    {
        if ( [song isDifficultyAvailable:(TMSongDifficulty) dif] )
        {
            NSString *title = [NSString stringWithFormat:@"%@ (%d)", [TMSong difficultyToString:(TMSongDifficulty) dif], [song getDifficultyLevel:(TMSongDifficulty) dif]];

            TMLog(@"Add dif %d to toggler as [%@]", dif, title);
            [m_pDifficultyToggler addItem:[NSNumber numberWithInt:dif] withTitle:title];

            if ( dif == prefDiff || abs(prefDiff - dif) < abs(prefDiff - closestDiffAvailable) )
            {
                closestDiffAvailable = dif;
                TMLog(@"Selected [%d <= %d] %@", dif, prefDiff, [TMSong difficultyToString:(TMSongDifficulty) dif]);
            }
        }
    }

    // Set the diff to closest found
    [m_pDifficultyToggler selectItemAtIndex:[m_pDifficultyToggler findIndexByValue:[NSNumber numberWithInt:closestDiffAvailable]]];
    g_pGameState->m_nSelectedDifficulty = (TMSongDifficulty) closestDiffAvailable;
    [m_pSongWheel updateAllWithDifficulty:(TMSongDifficulty) closestDiffAvailable];

    // Save as last played/selected
    [[SettingsEngine sharedInstance] setStringValue:song.m_sHash forKey:@"lastsong"];

    if ( song.bannerTexture != nil )
    {
        t_Banner = song.bannerTexture;
    }
    else
    {
        t_Banner = t_NoBanner;
    }

    // Update song banner
    [m_pBanner updateImage:t_Banner];

    // Update bpm display and CDTitle with currently selected song
    [m_pBpmDisplay updateWithSong:song];
    [m_pCDTitleDisplay updateWithSong:song];

    // Update score display
    [m_pSongWheel updateScore];

    // Mark released to prevent memleaks
    [selected release];
}

- (void)songShouldStart
{
    // Stop the preview music timer
    if ( self.m_previewMusicTimer )
    {
        [self.m_previewMusicTimer invalidate];
        self.m_previewMusicTimer = nil;
    }

    // Stop current previewMusic if any
    if ( m_pPreviewMusic )
    {
        [[TMSoundEngine sharedInstance] stopMusic];
    }

    // Play select sound effect
    [[TMSoundEngine sharedInstance] playEffect:sr_SelectSong];

    SongPickerMenuItem *selected = [m_pSongWheel getSelected];
    TMSong *song = [selected song];

    // Assign difficulty
    g_pGameState->m_nSelectedDifficulty = (TMSongDifficulty) [(NSNumber *) [m_pDifficultyToggler getCurrent].m_pValue intValue];

    // Check speedmod to be sure
    NSArray *speedMods = ARRAY_METRIC(@"SpeedMods");
    NSString *cur = [speedMods objectAtIndex:[[SettingsEngine sharedInstance] getIntValue:@"prefspeed"]];


    g_pGameState->m_pSong = [song retain];

    // Fixme: this is dirty :)
    NSArray *arr = [cur componentsSeparatedByString:@","];
    g_pGameState->m_sMods = [[arr objectAtIndex:[arr count] - 1] retain];

    if ( g_pGameState->m_bModDark )
    {
        g_pGameState->m_sMods = [[g_pGameState->m_sMods stringByAppendingFormat:@", %@", @"dark"] retain];
    }
    if ( g_pGameState->m_bModHidden )
    {
        g_pGameState->m_sMods = [[g_pGameState->m_sMods stringByAppendingFormat:@", %@", @"hidden"] retain];
    }
    if ( g_pGameState->m_bModSudden )
    {
        g_pGameState->m_sMods = [[g_pGameState->m_sMods stringByAppendingFormat:@", %@", @"sudden"] retain];
    }
    if ( g_pGameState->m_bModStealth )
    {
        g_pGameState->m_sMods = [[g_pGameState->m_sMods stringByAppendingFormat:@", %@", @"stealth"] retain];
    }

    [[TapMania sharedInstance] switchToScreen:[SongPlayRenderer class] withMetrics:@"SongPlay"];
}

/* Support last difficulty setting saving */
- (void)difficultyChanged
{
    int curDiff = [(NSNumber *) [m_pDifficultyToggler getCurrent].m_pValue intValue];
    TMLog(@"Changed difficulty. save. [%d => %@]", curDiff, [TMSong difficultyToString:(TMSongDifficulty) curDiff]);

    [[SettingsEngine sharedInstance] setIntValue:curDiff forKey:@"prefdiff"];
    g_pGameState->m_nSelectedDifficulty = (TMSongDifficulty) curDiff;
    [m_pSongWheel updateAllWithDifficulty:(TMSongDifficulty) curDiff];
    [m_pSongWheel updateScore];
}

/* Handle back button */
- (void)backButtonHit
{
    // Stop current previewMusic if any
    if ( m_pPreviewMusic )
    {
        [[TMSoundEngine sharedInstance] stopMusic];
    }
}

- (void)dealloc
{
    [m_pPreviewMusic release];
    [_m_previewMusicTimer release];
    [super dealloc];
}

@end
