//
//  TapManiaAppDelegate.m
//  TapMania
//  This class is based on the example source code in CrashLanding.
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright Godexsoft 2008. All rights reserved.
//

#import <mach/mach_time.h>
#import <syslog.h>

#import "TapManiaAppDelegate.h"
#import "EAGLView.h"

#import "TMRunLoop.h"
#import "TMRenderable.h"
#import "TMLogicUpdater.h"

#import "TexturesHolder.h"
#import "SoundEffectsHolder.h"
#import "SongsDirectoryCache.h"

#import "TMSong.h"
#import "TMSongOptions.h"

#import "SongPlayRenderer.h"

#define kListenerDistance			1.0  // Used for creating a realistic sound field

#define RANDOM_SEED() srandom((unsigned)(mach_absolute_time() & 0xFFFFFFFF))
#define RANDOM_FLOAT() ((float)random() / (float)INT32_MAX)

@implementation TapManiaAppDelegate

@synthesize joyPad;

+ (void) initialize {
	if(self == [TapManiaAppDelegate class]) {
		RANDOM_SEED();
	}
}

- (void) applicationDidFinishLaunching:(UIApplication*)application {
	//Setup the game
	_state = kState_StandBy;
	
	// Cache all songs
	[SongsDirectoryCache sharedInstance];
	
	// Load all sounds
	[SoundEffectsHolder sharedInstance];
			
	// Initialize the JoyPad
	// joyPad = [[JoyPad alloc] initWithStyle:kJoyStyleIndex];	
	// [joyPad setDelegate:self];
		
	[UIApplication sharedApplication].idleTimerDisabled = YES;	
	[NSThread setThreadPriority:0.9];

	// Start engines
	[RenderEngine sharedInstance];
	[LogicEngine sharedInstance];
	
	// Start with main menu
	SongPlayRenderer* mmRenderer = [[SongPlayRenderer alloc] init];
	NSArray* songList = [[SongsDirectoryCache sharedInstance] getSongList];
	// CreditsRenderer* mmRenderer = [[CreditsRenderer alloc] init];
	
	int i;
	for(i=0; i<[songList count]; i++){
		TMSong *song = [songList objectAtIndex:i];
		TMSongOptions* opts = [[TMSongOptions alloc] init];
		opts.speedMod = kSpeedMod_2x;
		opts.difficulty = kSongDifficulty_Hard;
		
		[mmRenderer playSong:song withOptions:opts];
		break;		
	}	
	
	[[RenderEngine sharedInstance] registerRenderer:mmRenderer withPriority:kRunLoopPriority_Highest];	
	[[LogicEngine sharedInstance] registerLogicUpdater:mmRenderer withPriority:kRunLoopPriority_Highest];	
}

- (void) showJoyPad {
	// [window addSubview:joyPad];
}

- (void) hideJoyPad {
	[joyPad removeFromSuperview];
}

// Release resources when they are no longer needed
- (void) dealloc {
	[joyPad release];
	
	[super dealloc];
}

# pragma mark JoyPad Delegate
- (void) joyPadStatusUpdated {
}

@end
