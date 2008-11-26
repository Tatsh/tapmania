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
#import "MainMenuRenderer.h"

#import "TMSong.h"
#import "TMSongOptions.h"

#define kUserNameDefaultKey			@"userName"   // NSString

#define kListenerDistance			1.0  // Used for creating a realistic sound field

#define RANDOM_SEED() srandom((unsigned)(mach_absolute_time() & 0xFFFFFFFF))
#define RANDOM_FLOAT() ((float)random() / (float)INT32_MAX)

@implementation TapManiaAppDelegate

@synthesize window;
@synthesize joyPad;

+ (void) initialize {
	if(self == [TapManiaAppDelegate class]) {
		RANDOM_SEED();
	}
}

- (void) applicationDidFinishLaunching:(UIApplication*)application {
	CGRect					rect = [[UIScreen mainScreen] bounds];	
	
	// Setup window
	self.window = [[[UIWindow alloc] initWithFrame:rect] autorelease];
	glView = [[EAGLView alloc] initWithFrame:[window bounds]];
	
	[window makeKeyAndVisible];
	
	//Setup the game
	_state = kState_StandBy;
	
	// Cache all songs
	[SongsDirectoryCache sharedInstance];
	
	// Load all textures
	[TexturesHolder sharedInstance];
	
	// Load all sounds
	[SoundEffectsHolder sharedInstance];
		
	//Set up OpenGL projection matrix
	glMatrixMode(GL_PROJECTION);
	glOrthof(0, rect.size.width, 0, rect.size.height, -1, 1);
	glMatrixMode(GL_MODELVIEW);
	
	//Initialize OpenGL states
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_TEXTURE_2D);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

	glBindTexture(GL_TEXTURE_2D, [[[TexturesHolder sharedInstance] getTexture:kTexture_Title] name]);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	
	// Initialize the JoyPad
	joyPad = [[JoyPad alloc] initWithStyle:kJoyStyleIndex];	
	[joyPad setDelegate:self];
	
	//Render the Title frame 
	glDisable(GL_BLEND);
	[[[TexturesHolder sharedInstance] getTexture:kTexture_Title] drawInRect:[glView bounds]];
	glEnable(GL_BLEND);
		
	[window addSubview:glView];
	NSLog(@"Added subview: glView.");
		
	// [(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] activateRenderer:cRenderer looping:NO];
	[(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] deactivateRendering];
	[UIApplication sharedApplication].idleTimerDisabled = YES;
	
	NSLock* lock = [[NSLock alloc] init];
	logicLoop = [[TMRunLoop alloc] initWithName:@"Logic" type:@protocol(TMLogicUpdater) andLock:lock];
	renderLoop = [[TMRunLoop alloc] initWithName:@"Render" type:@protocol(TMRenderable) andLock:lock];
	
	// Initially we start with the main menu
	MainMenuRenderer* mmRenderer = [[MainMenuRenderer alloc] initWithView:glView];
	[self registerRenderer:mmRenderer withPriority:kRunLoopPriority_Highest];
	
	// Run both loops	
	[logicLoop run];
	[renderLoop run];
		
	//Swap the framebuffer
	[glView swapBuffers];
	NSLog(@"Should draw already!");
}

- (void) showJoyPad {
	[window addSubview:joyPad];
}

- (void) hideJoyPad {
	[joyPad removeFromSuperview];
}

// Add a renderer to the render loop
- (void) registerRenderer:(AbstractRenderer*) renderer withPriority:(TMRunLoopPriority) priority {
	[renderLoop registerObject:renderer withPriority:priority];
}

- (void) clearRenderers {
	[renderLoop deregisterAllObjects];
}

// Stop calling the renderScene method constantly
- (void) deactivateRendering {
	[_timer release];
	[UIApplication sharedApplication].idleTimerDisabled = NO;
}

// Release resources when they are no longer needed
- (void) dealloc {
	[joyPad release];
	[currentRenderer release];
	[glView release];
	[window release];
	
	[super dealloc];
}

# pragma mark JoyPad Delegate
- (void) joyPadStatusUpdated {
}

@end
