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
#import "InputEngine.h"
#import "ThemeManager.h"
#import "EAGLView.h"

#import "TMRunLoop.h"	// TMRunLoopPriority
#import "JoyPad.h"
#import "SongsCacheLoaderRenderer.h"


// This is a singleton class, see below
static TapMania *sharedTapManiaDelegate = nil;

@implementation TapMania

@synthesize m_pGlView, m_pWindow;

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	// Defaults
	m_pCurrentSong = nil;
	m_pCurrentSongOptions = nil;
	m_pCurrentScreen = nil;

	// Load up graphics system
	CGRect rect = [[UIScreen mainScreen] bounds];	
	
	// Setup window
	m_pWindow = [[[UIWindow alloc] initWithFrame:rect] autorelease];
	
	// Show window
	[m_pWindow makeKeyAndVisible];
	
	// Init opengl
	m_pGlView = [[EAGLView alloc] initWithFrame:rect];	
	m_pGlView.multipleTouchEnabled = YES;	
	
	// Load theme. FIXME: hardcoded default theme here!
	[[ThemeManager sharedInstance] selectTheme:kDefaultThemeName];
	[[ThemeManager sharedInstance] selectNoteskin:kDefaultNoteSkinName];
	
	// Load all sounds
	[SoundEffectsHolder sharedInstance];
	
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
	[[[ThemeManager sharedInstance] texture:@"MainMenu Background"] drawInRect:self.m_pWindow.bounds];
	glEnable(GL_BLEND);
	
	[m_pGlView swapBuffers];
	NSLog(@"SWAP BUFFERS DONE!");
	
	[m_pWindow addSubview:m_pGlView];		
	
	// FIXME: hardcoded style here
	m_pJoyPad = [[JoyPad alloc] initWithStyle:kJoyStyleIndex];
		
	// Init main run loop
	m_pGameRunLoop = [[TMRunLoop alloc] init];
	[m_pGameRunLoop delegate:self];
	
	return self;
}

- (void) switchToScreen:(AbstractRenderer*)screenRenderer {
	NSLog(@"Switch to screen requested!");
	[m_pGameRunLoop registerSingleTimeTask:[[BasicTransition alloc] initFromScreen:m_pCurrentScreen toScreen:screenRenderer]];
}

- (void) registerObject:(NSObject*) obj withPriority:(TMRunLoopPriority) priority {
	[m_pGameRunLoop registerObject:obj withPriority:priority];
}

- (void) deregisterAll {
	[m_pGameRunLoop deregisterAllObjects];
}

- (void) setCurrentScreen:(AbstractRenderer*)screenRenderer {
	m_pCurrentScreen = screenRenderer;
}

- (void) releaseCurrentScreen {
	if(m_pCurrentScreen != nil){
		[m_pCurrentScreen release];
	}
}
   
- (void) startGame {
	[m_pGameRunLoop run];	
}

- (JoyPad*) enableJoyPad {
	[m_pJoyPad reset];
	[[InputEngine sharedInstance] subscribe:m_pJoyPad];
	return m_pJoyPad;
}

- (void) disableJoyPad {
	[[InputEngine sharedInstance] unsubscribe:m_pJoyPad];
}

/* Run loop delegate work */
- (void) runLoopInitHook {
	NSLog(@"Init game run loop...");
}

- (void) runLoopInitializedNotification {
	// Will start with main menu
	[[TapMania sharedInstance] switchToScreen:[[SongsCacheLoaderRenderer alloc] init]];
	
	NSLog(@"Game run loop initialized...");
}

- (void) runLoopBeforeHook:(NSNumber*)fDelta {
	// We must let the system handle all the events too
	while( CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.009, FALSE) == kCFRunLoopRunHandledSource);
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
