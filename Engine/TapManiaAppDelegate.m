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

#import "SongPlayRenderer.h"
#import "CreditsRenderer.h"

#import "TMSong.h"
#import "TMSongOptions.h"

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

	[RenderEngine sharedInstance];
}


/* Run loop delegate work */
- (void) runLoopInitHook {
	NSLog(@"Init separate logic thread...");
	[NSThread setThreadPriority:1.0];
}

- (void) runLoopInitializedNotification {
}

- (void) runLoopAfterHook:(NSNumber*)fDelta {
	// Give other threads some more time to focus on their job
	[NSThread sleepForTimeInterval:0.0001f];
}

- (void) runLoopActionHook:(NSArray*)args {
	NSObject* obj = [args objectAtIndex:0];
	NSNumber* fDelta = [args objectAtIndex:1];
	
	if([obj conformsToProtocol:@protocol(TMLogicUpdater)]){
		
		// Call the update method on the object
		[obj performSelector:@selector(update:) withObject:fDelta];
		
	} else {
		NSException* ex = [NSException exceptionWithName:@"UnknownObjType" 
												  reason:[NSString stringWithFormat:
														  @"The object you have passed [%@] into the runLoop doesn't conform to protocol [%s].", 
														  [obj class], [@protocol(TMLogicUpdater) name]] 
												userInfo:nil];
		@throw(ex);
	}	
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
