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
//#import "FlurryAPI.h"

@interface SongsCacheLoaderRenderer (Private)
- (void) worker;
- (void) generateTexture;
@end

@implementation SongsCacheLoaderRenderer

- (id) init {
	self = [super initWithMetrics:@"SongsCacheLoader"];
	if(!self)
		return nil;
	
	m_bTransitionIsDone = NO;
	m_bAllSongsLoaded = NO;
	m_bGlobalError = NO;
	
	m_sCurrentMessage = @"Start loading songs...";
	
	return self;
}

- (void) worker {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Do the caching
	[[SongsDirectoryCache sharedInstance] delegate:self];
	[[SongsDirectoryCache sharedInstance] cacheSongs];
	
	[pool drain];
}

- (void) generateTexture {
	if(	m_bTextureShouldChange ) { 
		[m_pCurrentStr updateText:m_sCurrentMessage];
	}
}

- (void) dealloc {
	[m_pThread release];
	[m_pLock release];
	
	[m_pCurrentStr release];
	
	[super dealloc];
}

/* TMTransitionSupport methods */
- (void) setupForTransition {
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
	
//	[FlurryAPI logEvent:@"start_loading_songs" timed:YES];
	
	// Start the song cache thread
	[m_pThread start];
}

- (void) beforeTransition {
	// Stop current music
	[[TMSoundEngine sharedInstance] stopMusicFading:0.3f];		
}

- (void) afterTransition {
	m_bTransitionIsDone = YES;
}

/* TMRenderable method */
- (void) render:(float)fDelta {
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
- (void) update:(float)fDelta {	
	[super update:fDelta];
	
	static double tickCounter = 0.0;
	
	if(m_bAllSongsLoaded && m_bTransitionIsDone) {
		TMLog(@"Requesting switch to main screen!");
//		[FlurryAPI endTimedEvent:@"start_loading_songs"];
		
		[[TapMania sharedInstance] switchToScreen:[MainMenuRenderer class] withMetrics:@"MainMenu"];
		m_bAllSongsLoaded = NO; // Do this only once
		
	} else if(m_bGlobalError) {
		tickCounter += fDelta;
		
		if(tickCounter >= 10.0) {
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
- (void) startLoadingSong:(NSString*) path {
	[m_pLock lock];
	m_sCurrentMessage = [NSString stringWithFormat:@"Loading song '%@'", path];
	m_bTextureShouldChange = YES;	
	[m_pLock unlock];
}

- (void) doneLoadingSong:(NSString*) path {
	[m_pLock lock];
	m_sCurrentMessage = [NSString stringWithFormat:@"Loading song '%@' done", path];
	m_bTextureShouldChange = YES;
	
	
	// Report the songs users play to determine the most uploaded
//	[FlurryAPI logEvent:@"load_song" withParameters:[NSDictionary dictionaryWithObject:path forKey:@"song"]];
	
	[m_pLock unlock];
}

- (void) errorLoadingSong:(NSString*) path withReason:(NSString*) message {
	[m_pLock lock];
	m_sCurrentMessage = [NSString stringWithFormat:@"ERROR Loading song '%@': %@", path, message];
	m_bTextureShouldChange = YES;
	[m_pLock unlock];
	
	// Sleep some time to let the user see the error
	[NSThread sleepForTimeInterval:3.0f];
}

- (void) songLoaderError:(NSString*) message {
	TMLog(@"Got song loader error!");
	[m_pLock lock];
	
	m_sCurrentMessage = [NSString stringWithFormat:@"ERROR: %@", message];
	TMLog(@"Message: %@", m_sCurrentMessage);

	m_bTextureShouldChange = YES;
	
	m_bGlobalError = YES;
	[m_pLock unlock];	
	
	[NSThread sleepForTimeInterval:10.0f];
}

- (void) songLoaderFinished {
	[m_pLock lock];
	m_bTextureShouldChange = YES;
	m_bAllSongsLoaded = YES;
	m_sCurrentMessage = @"All songs loaded...";
	[m_pLock unlock];
}
						

@end
