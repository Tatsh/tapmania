//
//  $Id$
//  SongsCacheLoaderRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 22.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "SongsCacheLoaderRenderer.h"
#import "TapMania.h"
#import "MainMenuRenderer.h"
#import "SongsDirectoryCache.h"
#import "FontString.h"
#import "EAGLView.h"
#import "ThemeManager.h"
#import "TMSoundEngine.h"
#import "TMSound.h"
#import "GLUtil.h"
#import "TMSong.h"
#import "Texture2D.h"
#import "Flurry.h"

@interface SongsCacheLoaderRenderer (Private)
- (void)worker;

- (void)generateTexture;
@end

@interface SongsCacheLoaderRenderer ()
- (void)loadBannerForSong:(TMSong *)song;

@end

@implementation SongsCacheLoaderRenderer

- (id)init
{
    self = [super initWithMetrics:@"SongsCacheLoader"];
    if ( !self )
    {
        return nil;
    }

    m_bTransitionIsDone = NO;
    m_bAllSongsLoaded = NO;
    m_bGlobalError = NO;

    m_sCurrentMessage = @"Start loading songs...";

    return self;
}

- (void)worker
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Do the caching
    [[SongsDirectoryCache sharedInstance] delegate:self];
    [[SongsDirectoryCache sharedInstance] cacheSongs];

    [pool drain];
}

- (void)generateTexture
{
    if ( m_bTextureShouldChange )
    {
        [m_pCurrentStr updateText:m_sCurrentMessage];
    }
}

- (void)dealloc
{
    [m_pThread release];
    [m_pLock release];

    [m_pCurrentStr release];

    [super dealloc];
}

/* TMTransitionSupport methods */
- (void)setupForTransition
{
    [super setupForTransition];

    // Cache textures / sounds
    sr_BG = SOUND(@"SongsCacheLoader Music");

    mt_Message = POINT_METRIC(@"SongsCacheLoader Message");

    m_pThread = [[NSThread alloc] initWithTarget:self selector:@selector(worker) object:nil];
    m_pLock = [[NSLock alloc] init];

    // Start the music
    [[TMSoundEngine sharedInstance] addToQueue:sr_BG];

    // Create a dynamic font string
    m_pCurrentStr = [[FontString alloc] initWithFont:@"SongsCacheLoader" andText:m_sCurrentMessage];
    m_pCurrentStr.alignment = UITextAlignmentCenter;

    m_bTextureShouldChange = YES;

    // Make sure we have the instance initialized on the main pool
    [SongsDirectoryCache sharedInstance];

    [Flurry logEvent:@"start_loading_songs" timed:YES];

    // Start the song cache thread
    [m_pThread start];
}

- (void)beforeTransition
{
    // Stop current music
    [[TMSoundEngine sharedInstance] stopMusicFading:0.3f];
}

- (void)afterTransition
{
    m_bTransitionIsDone = YES;
}

/* TMRenderable method */
- (void)render:(float)fDelta
{
    [super render:fDelta];
    TMBindTexture(0);

    [m_pLock lock];
    glEnable(GL_BLEND);
    [m_pCurrentStr drawAtPoint:mt_Message];
    TMLog(@"RENDER STRING '%@'", m_sCurrentMessage);
    glDisable(GL_BLEND);
    [m_pLock unlock];
}

/* TMLogicUpdater stuff */
- (void)update:(float)fDelta
{
    [super update:fDelta];

    static double tickCounter = 0.0;

    if ( m_bAllSongsLoaded && m_bTransitionIsDone )
    {
        TMLog(@"Requesting switch to main screen!");
        [Flurry endTimedEvent:@"start_loading_songs" withParameters:nil];

        [[TapMania sharedInstance] switchToScreen:[MainMenuRenderer class] withMetrics:@"MainMenu"];
        m_bAllSongsLoaded = NO; // Do this only once

    }
    else if ( m_bGlobalError )
    {
        tickCounter += fDelta;

        if ( tickCounter >= 10.0 )
        {
            TMLog(@"Time to die...");

            // Timeout and die
            exit(EXIT_FAILURE);
        }

    }

    [m_pLock lock];
    [self generateTexture];
    [m_pLock unlock];
}

/* TMSongsLoaderSupport stuff */
- (void)startLoadingSong:(NSString *)path
{
    [m_pLock lock];
    m_sCurrentMessage = [NSString stringWithFormat:@"Loading song '%@'", path];
    m_bTextureShouldChange = YES;
    [m_pLock unlock];
}

- (void)doneLoadingSong:(TMSong *)song withPath:(NSString *)path
{
    [m_pLock lock];
    m_sCurrentMessage = [NSString stringWithFormat:@"Loading song '%@' done", path];
    m_bTextureShouldChange = YES;

    [song performSelectorOnMainThread:@selector(reloadScores)
                           withObject:nil waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(loadBannerForSong:)
                           withObject:song waitUntilDone:NO];

    // Report the songs users play to determine the most uploaded
    [Flurry logEvent:@"load_song" withParameters:[NSDictionary dictionaryWithObject:path forKey:@"song"]];

    [m_pLock unlock];
}

- (void)loadBannerForSong:(TMSong *)song
{
    NSString *songPath = [[SongsDirectoryCache sharedInstance] getSongsPath:song.m_iSongsPath];
    songPath = [songPath stringByAppendingPathComponent:song.m_sSongDirName];

    NSString *bannerFilePath = [songPath stringByAppendingPathComponent:song.m_sBannerFilePath];
    TMLog(@"Banner full path: '%@'", bannerFilePath);

    UIImage *img = [UIImage imageWithContentsOfFile:bannerFilePath];
    if ( img )
    {
        TMLog(@"Allocating banner texture on song cache sync...");
        song.bannerTexture = [[[Texture2D alloc] initWithImage:img columns:1 andRows:1] autorelease];
    }

    // also load cd title
    if ( song.m_sCDTitleFilePath != nil )
    {
        NSString *cdFilePath = [songPath stringByAppendingPathComponent:song.m_sCDTitleFilePath];

        img = [UIImage imageWithContentsOfFile:cdFilePath];
        if ( img )
        {
            TMLog(@"Allocating CD title texture on song cache sync...");
            song.cdTitleTexture = [[[Texture2D alloc] initWithImage:img columns:1 andRows:1] autorelease];
        }
    }
}

- (void)errorLoadingSong:(NSString *)path withReason:(NSString *)message
{
    [m_pLock lock];
    m_sCurrentMessage = [NSString stringWithFormat:@"ERROR Loading song '%@': %@", path, message];
    m_bTextureShouldChange = YES;
    [m_pLock unlock];

    // Sleep some time to let the user see the error
    [NSThread sleepForTimeInterval:3.0f];
}

- (void)songLoaderError:(NSString *)message
{
    TMLog(@"Got song loader error!");
    [m_pLock lock];

    m_sCurrentMessage = [NSString stringWithFormat:@"ERROR: %@", message];
    TMLog(@"Message: %@", m_sCurrentMessage);

    m_bTextureShouldChange = YES;

    m_bGlobalError = YES;
    [m_pLock unlock];

    [NSThread sleepForTimeInterval:10.0f];
}

- (void)songLoaderFinished
{
    [m_pLock lock];
    m_bTextureShouldChange = YES;
    m_bAllSongsLoaded = YES;
    m_sCurrentMessage = @"All songs loaded...";
    [m_pLock unlock];
}


@end
