//
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
#import "Texture2D.h"
#import "EAGLView.h"
#import "ThemeManager.h"

@interface SongsCacheLoaderRenderer (Private)
- (void) worker;
- (void) generateTexture;
@end

@implementation SongsCacheLoaderRenderer

Texture2D* t_SongsLoaderBG;

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	// Cache textures
	t_SongsLoaderBG = [[ThemeManager sharedInstance] texture:@"SongsLoader Background"];
	
	m_bAllSongsLoaded = NO;
	m_bGlobalError = NO;
	
	m_pThread = [[NSThread alloc] initWithTarget:self selector:@selector(worker) object:nil];	
	m_pLock = [[NSLock alloc] init];
	
	m_pCurrentTexture = nil;
	m_sCurrentMessage = @"Start loading songs...";
	m_bTextureShouldChange = YES;
	
	// Make sure we have the instance initialized on the main pool
	[SongsDirectoryCache sharedInstance];
	
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
		if( m_pCurrentTexture != nil ) {
			[m_pCurrentTexture release];
		}
		
		m_pCurrentTexture = [[Texture2D alloc] initWithString:m_sCurrentMessage dimensions:CGSizeMake(320,20) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:16];
	}
}

- (void) dealloc {
	[m_pThread release];
	[m_pLock release];
	
	[m_pCurrentTexture release];
	
	[super dealloc];
}

/* TMTransitionSupport methods */
- (void) setupForTransition {
	// Start the song cache thread
	[m_pThread start];
}

- (void) deinitOnTransition {
}

/* TMRenderable method */
- (void) render:(NSNumber*)fDelta {
	CGRect bounds = [TapMania sharedInstance].glView.bounds;
	
	// Draw background
	[t_SongsLoaderBG drawInRect:bounds];

	[m_pLock lock];
	if(m_pCurrentTexture != nil) {
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		[m_pCurrentTexture drawInRect:CGRectMake(0, 50, 320, 15)];		
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
		glDisable(GL_BLEND);
	}
	[m_pLock unlock];
}

/* TMLogicUpdater stuff */
- (void) update:(NSNumber*)fDelta {	
	static double tickCounter = 0;

	if(m_bAllSongsLoaded) {
		[[TapMania sharedInstance] switchToScreen:[[MainMenuRenderer alloc] init]];
		m_bAllSongsLoaded = NO; // Do this only once
		
	} else if(m_bGlobalError) {
		tickCounter += [fDelta floatValue];
		
		if(tickCounter >= 5.0) {
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
	[m_pLock lock];
	
	m_sCurrentMessage = [NSString stringWithFormat:@"ERROR: %@", message];
	m_bTextureShouldChange = YES;
	
	m_bGlobalError = YES;
	[m_pLock unlock];	
}

- (void) songLoaderFinished {
	[m_pLock lock];
	m_bTextureShouldChange = YES;
	m_bAllSongsLoaded = YES;
	m_sCurrentMessage = [[NSString stringWithString:@"All songs loaded..."] retain];
	[m_pLock unlock];
}
						

@end
