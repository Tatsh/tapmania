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
#import "TexturesHolder.h"

@interface SongsCacheLoaderRenderer (Private)
- (void) worker;
- (void) generateTexture;
@end

@implementation SongsCacheLoaderRenderer

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	_allSongsLoaded = NO;
	_globalError = NO;
	
	_thread = [[NSThread alloc] initWithTarget:self selector:@selector(worker) object:nil];	
	_lock = [[NSLock alloc] init];
	
	_currentTexture = nil;
	_currentMessage = @"Start loading songs...";
	_textureShouldChange = YES;
	
	// Make sure we have the instance initialized on the main pool
	[SongsDirectoryCache sharedInstance];
	
	return self;
}

- (void) worker {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Do the caching
	[SongsDirectoryCache sharedInstance].delegate = self;
	[[SongsDirectoryCache sharedInstance] cacheSongs];
	
	[pool drain];
}

- (void) generateTexture {
	if(	_textureShouldChange ) { 
		if( _currentTexture != nil ) {
			[_currentTexture release];
		}
		
		_currentTexture = [[Texture2D alloc] initWithString:_currentMessage dimensions:CGSizeMake(320,20) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:16];
	}
}

- (void) dealloc {
	[_thread release];
	[_lock release];
	
	[_currentTexture release];
	
	[super dealloc];
}

/* TMTransitionSupport methods */
- (void) setupForTransition {
	// Start the song cache thread
	[_thread start];
}

- (void) deinitOnTransition {
}

/* TMRenderable method */
- (void) render:(NSNumber*)fDelta {
	CGRect bounds = [TapMania sharedInstance].glView.bounds;
	
	// Draw background
	glDisable(GL_BLEND);
	[[[TexturesHolder sharedInstance] getTexture:kTexture_MainMenuBackground] drawInRect:bounds];
	glEnable(GL_BLEND);

	[_lock lock];
	if(_currentTexture != nil) {
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		[_currentTexture drawInRect:CGRectMake(0, 50, 320, 15)];		
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	}
	[_lock unlock];
}

/* TMLogicUpdater stuff */
- (void) update:(NSNumber*)fDelta {	
	static double tickCounter = 0;

	if(_allSongsLoaded) {
		[[TapMania sharedInstance] switchToScreen:[[MainMenuRenderer alloc] init]];
		_allSongsLoaded = NO; // Do this only once
		
	} else if(_globalError) {
		tickCounter += [fDelta floatValue];
		
		if(tickCounter >= 5.0) {
			// Timeout and die
			exit(EXIT_FAILURE);
		}
		
	}
	
	[_lock lock];
	[self generateTexture];
	[_lock unlock];
}

/* TMSongsLoaderSupport stuff */
- (void) startLoadingSong:(NSString*) path {
	[_lock lock];
	_currentMessage = [NSString stringWithFormat:@"Loading song '%@'", path];
	_textureShouldChange = YES;
	[_lock unlock];
}

- (void) doneLoadingSong:(NSString*) path {
	[_lock lock];
	_currentMessage = [NSString stringWithFormat:@"Loading song '%@' done", path];
	_textureShouldChange = YES;
	[_lock unlock];
}

- (void) errorLoadingSong:(NSString*) path withReason:(NSString*) message {
	[_lock lock];
	_currentMessage = [NSString stringWithFormat:@"ERROR Loading song '%@': %@", path, message];
	_textureShouldChange = YES;
	[_lock unlock];
	
	// Sleep some time to let the user see the error
	[NSThread sleepForTimeInterval:3.0f];
}

- (void) songLoaderError:(NSString*) message {
	[_lock lock];
	
	_currentMessage = [NSString stringWithFormat:@"ERROR: %@", message];
	_textureShouldChange = YES;
	
	_globalError = YES;
	[_lock unlock];	
}

- (void) songLoaderFinished {
	[_lock lock];
	_textureShouldChange = YES;
	_allSongsLoaded = YES;
	_currentMessage = [[NSString stringWithString:@"All songs loaded..."] retain];
	[_lock unlock];
}
						

@end
