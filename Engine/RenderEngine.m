//
//  RenderEngine.m
//  TapMania
//
//  Created by Alex Kremer on 27.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "RenderEngine.h"
#import "TexturesHolder.h"
#import "SongPlayRenderer.h"
#import "TMSong.h"
#import "TMSteps.h"
#import "SongsDirectoryCache.h"
#import "TapManiaAppDelegate.h"

// This is a singleton class, see below
static RenderEngine *sharedRenderEngineDelegate = nil;

@implementation RenderEngine

@synthesize glView, window;

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	CGRect rect = [[UIScreen mainScreen] bounds];	
	
	// Setup window
	self.window = [[[UIWindow alloc] initWithFrame:rect] autorelease];
	
	// Show window
	[self.window makeKeyAndVisible];
		
	// Render loop initialization 	
	renderLock = [[NSLock alloc] init];
	renderRunLoop = [[TMRunLoop alloc] initWithName:@"Render" andLock:renderLock inMainThread:YES];
			
	// Set the delegate
	renderRunLoop.delegate = self;
	
	// Ready to start rendering.
	[renderRunLoop run];
	
	// Create the logic updater loop
	logicRunLoop = [[TMRunLoop alloc] initWithName:@"Logic" andLock:renderLock];
	logicRunLoop.delegate = (TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	[logicRunLoop run];
	
	return self;
}

// Add a renderer to the render loop
- (void) registerRenderer:(AbstractRenderer*) renderer withPriority:(TMRunLoopPriority) priority {
	[renderRunLoop registerObject:renderer withPriority:priority];
}

- (void) clearRenderers {
	[renderRunLoop deregisterAllObjects];
}


/* Run loop delegate work */
- (void) runLoopInitHook {
	NSLog(@"Init OpenGLES in a separate rendering thread...");
	
	CGRect rect = [window bounds];
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
		
	[glView swapBuffers];

	NSLog(@"Looks like inited!");
}

- (void) runLoopInitializedNotification {
	[self.window addSubview:glView];		
	NSLog(@"Added glView as subview!");
	
	// Initially we start with the main menu
	SongPlayRenderer* mmRenderer = [[SongPlayRenderer alloc] init];
	NSArray* songList = [[SongsDirectoryCache sharedInstance] getSongList];
	
	[self registerRenderer:mmRenderer withPriority:kRunLoopPriority_Highest];	
	[logicRunLoop registerObject:mmRenderer withPriority:kRunLoopPriority_Highest];	
	
	int i;
	for(i=0; i<[songList count]; i++){
		TMSong *song = [songList objectAtIndex:i];
		TMSongOptions* opts = [[TMSongOptions alloc] init];
		opts.speedMod = kSpeedMod_2x;
		opts.difficulty = kSongDifficulty_Hard;
		
		[mmRenderer playSong:song withOptions:opts];
		break;		
	}
}

- (void) runLoopActionHook:(NSArray*)args {
	NSObject* obj = [args objectAtIndex:0];
	NSNumber* fDelta = [args objectAtIndex:1];
	
	if([obj conformsToProtocol:@protocol(TMRenderable)]){

		// Call the render method on the object
		[obj performSelector:@selector(render:) withObject:fDelta];

	} else {
		NSException* ex = [NSException exceptionWithName:@"UnknownObjType" 
							  reason:[NSString stringWithFormat:
									  @"The object you have passed [%@] into the runLoop doesn't conform to protocol [%s].", 
									  [obj className], [@protocol(TMRenderable) name]] 
							userInfo:nil];
		@throw(ex);
	}	
}

 - (void) runLoopBeforeHook:(NSNumber*)fDelta {
	[self.glView preRender];
}

- (void) runLoopAfterHook:(NSNumber*)fDelta {
	[self.glView postRender];
	// [glView swapBuffers];
}

// Release resources when they are no longer needed
- (void) dealloc {
	[renderRunLoop deregisterAllObjects];
	[renderRunLoop release];
	
	[glView release];
	[window release];
	
	[super dealloc];
}

#pragma mark Singleton stuff

+ (RenderEngine *)sharedInstance {
    @synchronized(self) {
        if (sharedRenderEngineDelegate == nil) {
            [[self alloc] init];
        }
    }
    return sharedRenderEngineDelegate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedRenderEngineDelegate	== nil) {
            sharedRenderEngineDelegate = [super allocWithZone:zone];
            return sharedRenderEngineDelegate;
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
