//
//  $Id$
//  TapMania.mm
//  TapMania
//
//  Created by Alex Kremer on 02.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "TapMania.h"

#import "FadeTransition.h"
#import "SongsDirectoryCache.h"
#import "TMSoundEngine.h"
#import "InputEngine.h"
#import "SettingsEngine.h"
#import "ThemeManager.h"
#import "NewsFetcher.h"
#import "EAGLView.h"
#import "ARRollerView.h"
#import "MessageManager.h"
#import "TMMessage.h"
#import "TMScreen.h"
#import "TMModalView.h"

#import "TMRunLoop.h"	// TMRunLoopPriority
#import "JoyPad.h"
#import "SongsCacheLoaderRenderer.h"

#import "CommandParser.h"
#import "NameCommand.h"
#import "FontCommand.h"
#import "FontSizeCommand.h"
#import "AlignmentCommand.h"
#import "ScreenCommand.h"
#import "ValueCommand.h"
#import "SettingCommand.h"
#import "VolumeCommand.h"
#import "PlaySoundEffectCommand.h"
#import "SleepCommand.h"
#import "ModCommand.h"
#import "ZoomCommand.h"

#import "GameState.h"
#import "FPS.h"

TMGameState* g_pGameState;

// This is a singleton class, see below
static TapMania *sharedTapManiaDelegate = nil;

#define DEGTORAD(x) x*(3.14/180)

@implementation TapMania

@synthesize m_pGlView, m_pWindow, m_pJoyPad, m_pGameRunLoop, m_Transform, m_InputTransform;

- (id) init {
	self = [super init];
	if(!self)
		return nil;

	// Start the message manager and register some basic messages
	REG_MESSAGE(kApplicationStartedMessage, [@"ApplicationStarted" retain]);
	REG_MESSAGE(kApplicationShouldTerminateMessage, [@"ApplicationShouldTerminate" retain]);
	
	// Start command engine and register system commands
	REG_COMMAND([@"name" retain], [NameCommand class]);
	REG_COMMAND([@"font" retain], [FontCommand class]);
	REG_COMMAND([@"fontsize" retain], [FontSizeCommand class]);
	REG_COMMAND([@"alignment" retain], [AlignmentCommand class]);
	REG_COMMAND([@"sleep" retain], [SleepCommand class]);
	REG_COMMAND([@"mod" retain], [ModCommand class]);
	REG_COMMAND([@"screen" retain], [ScreenCommand class]);
	REG_COMMAND([@"value" retain], [ValueCommand class]);
	REG_COMMAND([@"setting" retain], [SettingCommand class]);
	REG_COMMAND([@"volume" retain], [VolumeCommand class]);
	REG_COMMAND([@"playsoundeffect" retain], [PlaySoundEffectCommand class]);
	REG_COMMAND([@"zoom" retain], [ZoomCommand class]);	
	
	// REG_COMMAND([@"" retain], );
	
	// Load up user configuration and cache
	[[SettingsEngine sharedInstance] loadUserConfig];
	g_pGameState = (TMGameState*)malloc(sizeof(TMGameState));
	g_pGameState->m_bLandscape = [[SettingsEngine sharedInstance] getBoolValue:@"landscape"] ;
	
	// Defaults
	m_pCurrentSong = nil;
	m_pCurrentSongOptions = nil;
	m_pCurrentScreen = nil;
	
	if(g_pGameState->m_bLandscape) {
		m_Transform = CGAffineTransformMakeTranslation(0.0f, 320.0f);	// For landscape
		m_Transform = CGAffineTransformScale(m_Transform, 1.0f, -1.0f);	
	
		m_InputTransform = CGAffineTransformMakeRotation(DEGTORAD(-90.0f));
		m_InputTransform = CGAffineTransformScale(m_InputTransform, 1.0f, -1.0f);	
		m_InputTransform = CGAffineTransformTranslate(m_InputTransform, -320.0f, -480.0f);		
		
		[UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
	} else {		
		m_Transform = CGAffineTransformMakeTranslation(0.0f, 480.0f);	// For skyscraper
		m_Transform = CGAffineTransformScale(m_Transform, 1.0f, -1.0f);			
		m_InputTransform = m_Transform;
	}
	
	return self;
}

- (void) switchToScreen:(Class)screenClass withMetrics:(NSString*)inMetrics {
	[self registerObjectAtBegin:[[FadeTransition alloc] initFromScreen:m_pCurrentScreen toClass:screenClass withMetrics:inMetrics]];
}

- (void) switchToScreen:(Class)screenClass withMetrics:(NSString*)inMetrics usingTransition:(Class)transitionClass {
	[self registerObjectAtBegin:[[transitionClass alloc] initFromScreen:m_pCurrentScreen toClass:screenClass withMetrics:inMetrics]];
}

- (void) switchToScreen:(Class)screenClass withMetrics:(NSString*)inMetrics usingTransition:(Class)transitionClass timeIn:(double)timeIn timeOut:(double) timeOut {
	[self registerObjectAtBegin:[[transitionClass alloc] initFromScreen:m_pCurrentScreen toClass:screenClass withMetrics:inMetrics timeIn:timeIn timeOut:timeOut]];
}

- (void) addOverlay:(TMModalView*)modalView {
	[self registerObjectAtEnd:modalView];
}

- (void) removeOverlay:(TMModalView*)modalView {
	[self deregisterObject:modalView];
	[modalView release];
}

- (void) registerObjectAtEnd:(NSObject*) obj {
	[m_pGameRunLoop pushBackChild:obj];
}

- (void) registerObjectAtBegin:(NSObject*) obj {
	[m_pGameRunLoop pushChild:obj];
}

- (void) deregisterObject:(NSObject*) obj {
	[m_pGameRunLoop removeObject:obj];
}

- (void) deregisterAll {
	[m_pGameRunLoop removeAllObjects];
}

- (void) deregisterCommandsForObject:(NSObject*) obj {
	[m_pGameRunLoop removeCommandsForObject:obj];
}

- (void) setCurrentScreen:(TMScreen*)screenRenderer {
	m_pCurrentScreen = screenRenderer;
}

- (void) releaseCurrentScreen {
	if(m_pCurrentScreen != nil){
		[m_pCurrentScreen release];
	}
}

- (void) startGame {
	// Alloc main run loop
	m_pGameRunLoop = [[TMRunLoop alloc] init];
	[m_pGameRunLoop delegate:self];	

	// And run it
	[m_pGameRunLoop performSelectorOnMainThread:@selector(run) withObject:nil waitUntilDone:NO];
	
	BROADCAST_MESSAGE(kApplicationStartedMessage, nil);
}

- (void) toggleAds:(BOOL)onOff {
	if(! onOff) {
		[m_pAdsView removeFromSuperview];
	} else {
		[m_pGlView addSubview:m_pAdsView];
		[m_pAdsView getNextAd];
	}
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
	TMLog(@"Init game run loop...");
	
	// Load up graphics system
	CGRect rect = [[UIScreen mainScreen] bounds];	
	
	// Setup window
	m_pWindow = [[[UIWindow alloc] initWithFrame:rect] autorelease];
	
	// Init global joypad
	m_pJoyPad = [[JoyPad alloc] init];
	
	// Init opengl
	if(g_pGameState->m_bLandscape) {	
		m_pGlView = [[EAGLView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 480.0f, 320.0f)];	
		
		m_pGlView.transform = CGAffineTransformIdentity;
		m_pGlView.transform = CGAffineTransformMakeRotation(DEGTORAD(-90.0f));
		m_pGlView.center = CGPointMake(160.0f, 240.0f);
	} else {
		m_pGlView = [[EAGLView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];			
	}

	m_pGlView.multipleTouchEnabled = YES;	
	
	// Init sound system and set the master volume from settings
	[[TMSoundEngine sharedInstance] setMasterVolume:[[SettingsEngine sharedInstance] getFloatValue:@"sound"]];
	[[TMSoundEngine sharedInstance] start];
	
	// Load theme graphics, sounds, fonts, etc.
	[[ThemeManager sharedInstance] selectTheme:[[SettingsEngine sharedInstance] getStringValue:@"theme"]];
	[[ThemeManager sharedInstance] selectNoteskin:[[SettingsEngine sharedInstance] getStringValue:@"noteskin"]];
		
	// Start fetching news
	[NewsFetcher sharedInstance];
	
	// Set up OpenGL projection matrix
	glMatrixMode(GL_PROJECTION);

	if(g_pGameState->m_bLandscape) {
		glOrthof(0, rect.size.height, 0, rect.size.width, -1, 1);
	} else {
		glOrthof(0, rect.size.width, 0, rect.size.height, -1, 1);
	}
	
	glMatrixMode(GL_MODELVIEW);
	
	// Initialize OpenGL states
	glDisable(GL_DEPTH_TEST);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_TEXTURE_2D);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glLoadIdentity();
	glClearColor(0,0,0,1.0f);
	
	// Clear
	glClear(GL_COLOR_BUFFER_BIT);

	// No lighting/depth testing
	glDisable( GL_DEPTH_TEST );
	glDisable( GL_LIGHTING );
	
	// Add the gl view to our main window
	[m_pWindow addSubview:m_pGlView];		

	// Create the AdWhirl thing
	m_pAdsView = [ARRollerView requestRollerViewWithDelegate:self];
	m_pAdsView.clipsToBounds = YES;
	
	if(g_pGameState->m_bLandscape) {
		[m_pAdsView setFrame:CGRectMake(80,270, 320, 50)];
	} else {
		[m_pAdsView setFrame:CGRectMake(0,430, 320, 50)];
	}
	
	[m_pGlView addSubview:m_pAdsView];
	TMLog(@"Added the AdWhirl view.");
	
	// Show window
	[m_pWindow makeKeyAndVisible];
	
	TMLog(@"Done initializing opengl");
}

- (void) runLoopInitializedNotification {
	// Show FPS in debug mode only. FPS rendering slows things a lot.
#ifdef DEBUG 
	[[TapMania sharedInstance] registerObjectAtEnd:[[FPS alloc] init]];	// FPS drawing
#endif
	
	// Will start with song loader
	[[TapMania sharedInstance] switchToScreen:[SongsCacheLoaderRenderer class] withMetrics:@"SongsCacheLoader" usingTransition:[FadeTransition class] timeIn:0.0f timeOut:0.5f];
		
	TMLog(@"Game run loop initialized...");
}

- (void) runLoopBeforeHook:(float)fDelta {
	// We must let the system handle all the events too
	while( CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.009, FALSE) == kCFRunLoopRunHandledSource);
}

- (void) runLoopAfterHook:(float)fDelta {
	// Must swap buffer after drawing
	[self.glView swapBuffers];
}

#pragma mark ARRollerDelegate required delegate method implementation
- (NSString*)adWhirlApplicationKey
{
	// 0.1.7 version
	return @"839677085bd3102d81f0fcd5368d21fc";
	
	// 0.1.6 -   return @"c7b13290e38c102c96dc5b26aef5c1e9";
}

#pragma mark ARRollerDelegate optional delegate method implementations

- (void)rollerDidReceiveAd:(ARRollerView*)adWhirlView
{
	TMLog(@"Received ad from %@!", [m_pAdsView mostRecentNetworkName]);
	
}
- (void)rollerDidFailToReceiveAd:(ARRollerView*)adWhirlView usingBackup:(BOOL)YesOrNo
{
	TMLog(@"Failed to receive ad from %@.  Using Backup: %@", [m_pAdsView mostRecentNetworkName], YesOrNo ? @"YES" : @"NO");
}

- (void)rollerReceivedRequestForDeveloperToFulfill:(ARRollerView*)adWhirlView
{
	TMLog(@"Received Generic Notification.  Use this notification to do anything you want, such as making a ad request call to an ad network");
}

- (void)willDisplayWebViewCanvas
{
	TMLog(@"A webview canvas will be displayed now because the user tapped on a banner ad.");
}

- (void)didDismissWebViewCanvas
{
	TMLog(@"The webview canvas will now disappear.");
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
