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

#import "TexturesHolder.h"
#import "SoundEffectsHolder.h"

#import "SongPlayRenderer.h"
#import "MainMenuRenderer.h"

#import "TMSong.h"
#import "TMSongOptions.h"

#define kUserNameDefaultKey			@"userName"   // NSString

#define kRenderingFPS				60.0 // Hz
#define kListenerDistance			1.0  // Used for creating a realistic sound field


#define RANDOM_SEED() srandom((unsigned)(mach_absolute_time() & 0xFFFFFFFF))
#define RANDOM_FLOAT() ((float)random() / (float)INT32_MAX)

@implementation TapManiaAppDelegate

@synthesize currentRenderer, window;

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
	joyPad = [[JoyPad alloc] initWithStyle:kJoyStyleSpread andFrame:CGRectMake(0, 400, 320, 80)];	
	[joyPad setDelegate:self];
	
	//Render the Title frame 
	glDisable(GL_BLEND);
	[[[TexturesHolder sharedInstance] getTexture:kTexture_Title] drawInRect:[glView bounds]];
	glEnable(GL_BLEND);
	
	// Show menu
	[self activateRenderer:[[MainMenuRenderer alloc] initWithView:glView] looping:NO];
		
	[window addSubview:glView];
	NSLog(@"Added subview: glView.");
	
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

// Set current renderer and start the renderScene invocation timer
- (void) activateRenderer:(AbstractRenderer*) renderer looping:(BOOL) looping {
	// Deactivate old renderer
	if([UIApplication sharedApplication].idleTimerDisabled) {
		[self deactivateRendering];
	}
	
	// Release old one
	[currentRenderer release];
	
	// Set new
	self.currentRenderer = renderer;

	if(!looping) {
		// Render scene once only
		[currentRenderer renderScene];
	} else {
		// Start rendering timer
		_timer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / kRenderingFPS) target:currentRenderer selector:@selector(renderScene) userInfo:nil repeats:YES];
		[UIApplication sharedApplication].idleTimerDisabled = YES;
	}
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