//
//  LogicEngine.m
//  TapMania
//
//  Created by Alex Kremer on 01.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TapMania.h"

#import "BasicTransition.h"
#import "SongsDirectoryCache.h"
#import "SoundEffectsHolder.h"
#import "TexturesHolder.h"

#import "MainMenuRenderer.h"


// This is a singleton class, see below
static TapMania *sharedTapManiaDelegate = nil;

@implementation TapMania

@synthesize glView, window;

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	// Defaults
	currentSong = nil;
	currentSongOptions = nil;
	currentScreen = nil;
	
	// Cache all songs
	[SongsDirectoryCache sharedInstance];
	
	// Load all sounds
	[SoundEffectsHolder sharedInstance];
	
	// Load up graphics system
	CGRect rect = [[UIScreen mainScreen] bounds];	
	
	// Setup window
	self.window = [[[UIWindow alloc] initWithFrame:rect] autorelease];
	
	// Show window
	[self.window makeKeyAndVisible];
	
	// Init opengl
	glView = [[EAGLView alloc] initWithFrame:rect];	
	
	// Load all textures
	[TexturesHolder sharedInstance];
	
	// Set up OpenGL projection matrix
	glMatrixMode(GL_PROJECTION);
	glOrthof(0, rect.size.width, 0, rect.size.height, -1, 1);
	glMatrixMode(GL_MODELVIEW);
	
	// Initialize OpenGL states
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_TEXTURE_2D);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	// Draw background first to avoid some odd effects with old graphics on the gpu
	glDisable(GL_BLEND);
	[[[TexturesHolder sharedInstance] getTexture:kTexture_MainMenuBackground] drawInRect:self.window.bounds];
	glEnable(GL_BLEND);
	
	[glView swapBuffers];
	NSLog(@"SWAP BUFFERS DONE!");
	
	[self.window addSubview:glView];		
	
	// FIXME: hardcoded index style here
	joyPad = [[JoyPad alloc] initWithStyle:kJoyStyleIndex];
	
	// Init main run loop
	gameRunLoop = [[TMRunLoop alloc] init];
	gameRunLoop.delegate = self;
	
	return self;
}

- (void) switchToScreen:(AbstractRenderer*)screenRenderer {
	NSLog(@"Switch to screen requested!");
	[gameRunLoop registerSingleTimeTask:[[BasicTransition alloc] initFromScreen:currentScreen toScreen:screenRenderer]];
}

- (void) registerObject:(NSObject*) obj withPriority:(TMRunLoopPriority) priority {
	[gameRunLoop registerObject:obj withPriority:priority];
}

- (void) deregisterAll {
	[gameRunLoop deregisterAllObjects];
}

- (void) setCurrentScreen:(AbstractRenderer*)screenRenderer {
	currentScreen = screenRenderer;
}

- (void) releaseCurrentScreen {
	if(currentScreen != nil){
		[currentScreen release];
	}
}
   
- (void) startGame {
	[gameRunLoop run];	
}

- (JoyPad*) enableJoyPad {
	[[InputEngine sharedInstance] subscribe:joyPad];
	return joyPad;
}

- (void) disableJoyPad {
	[[InputEngine sharedInstance] unsubscribe:joyPad];
}

/* Run loop delegate work */
- (void) runLoopInitHook {
	NSLog(@"Init game run loop...");
}

- (void) runLoopInitializedNotification {
	// Will start with main menu
	[[TapMania sharedInstance] switchToScreen:[[MainMenuRenderer alloc] init]];
	
	NSLog(@"Game run loop initialized...");
}

- (void) runLoopBeforeHook:(NSNumber*)fDelta {
	// We must let the system handle all the events too
	while( CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE) == kCFRunLoopRunHandledSource);
}

- (void) runLoopAfterHook:(NSNumber*)fDelta {
	// Must swap buffer after drawing
	[self.glView swapBuffers];
}

#pragma mark Singleton stuff

+ (TapMania *)sharedInstance {
    @synchronized(self) {
        if (sharedTapManiaDelegate == nil) {
            [[self alloc] init];
        }
    }
    return sharedTapManiaDelegate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedTapManiaDelegate	== nil) {
            sharedTapManiaDelegate = [super allocWithZone:zone];
            return sharedTapManiaDelegate;
        }
    }
	
    return nil;
}


- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
	// NOTHING
}

- (id)autorelease {
    return self;
}

@end
