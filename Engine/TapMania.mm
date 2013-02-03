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
#import "DialogCommand.h"
#import "ValueCommand.h"
#import "SettingCommand.h"
#import "VolumeCommand.h"
#import "PlaySoundEffectCommand.h"
#import "SleepCommand.h"
#import "ModCommand.h"
#import "ZoomCommand.h"

#import "TapDBCommand.h"

#import "TapManiaAppDelegate.h"
#import "GameState.h"
#import "FPS.h"

#import "TDBSearch.h"

#import "DisplayUtil.h"
#import "ICadeResponder.h"
#import "GameCenterManager.h"

TMGameState *g_pGameState;

// This is a singleton class, see below
static TapMania *sharedTapManiaDelegate = nil;

#define DEGTORAD(x) x*(3.14/180)

@interface TapMania ()
- (void)setupControllerMappings;

@end

@implementation TapMania
{
    std::map<iCadeState, JPButton> current_mapping_;
    std::map<std::string, std::map<iCadeState, JPButton> > mappings_;
}

@synthesize m_pGlView, m_pWindow, m_pJoyPad, m_pGameRunLoop, m_Transform, m_InputTransform;
@synthesize iCadeResponder = _iCadeResponder;


- (id)init
{
    self = [super init];
    if ( !self )
    {
        return nil;
    }

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
    REG_COMMAND([@"dialog" retain], [DialogCommand class]);
    REG_COMMAND([@"value" retain], [ValueCommand class]);
    REG_COMMAND([@"setting" retain], [SettingCommand class]);
    REG_COMMAND([@"volume" retain], [VolumeCommand class]);
    REG_COMMAND([@"playsoundeffect" retain], [PlaySoundEffectCommand class]);
    REG_COMMAND([@"zoom" retain], [ZoomCommand class]);

    REG_COMMAND([@"tapdb" retain], [TapDBCommand class]);


    // REG_COMMAND([@"" retain], );

    // Load up user configuration and cache
    [[SettingsEngine sharedInstance] loadUserConfig];
    g_pGameState = (TMGameState *) malloc(sizeof(TMGameState));
    g_pGameState->m_bLandscape = CFG_BOOL(@"landscape");

    // Drop all mods to default.
    // Potentially we would like to restore them from the cache instead
    g_pGameState->m_bModHidden = g_pGameState->m_bModSudden = g_pGameState->m_bModStealth = NO;
    g_pGameState->m_bModDark = NO;
    g_pGameState->m_dSpeedModValue = CFG_FLOAT(@"speedmod");
    g_pGameState->m_dGlobalOffset = CFG_DOUBLE(@"globalSyncOffset");
    g_pGameState->m_bIsGlobalSync = NO;

    // Defaults
    m_pCurrentSong = nil;
    m_pCurrentSongOptions = nil;
    m_pCurrentScreen = nil;

    CGSize dispSize = [DisplayUtil getDeviceDisplaySize];

    if ( g_pGameState->m_bLandscape )
    {
        m_Transform = CGAffineTransformMakeTranslation(0.0f, dispSize.width);    // For landscape
        m_Transform = CGAffineTransformScale(m_Transform, 1.0f, -1.0f);

        m_InputTransform = CGAffineTransformMakeRotation(DEGTORAD(-90.0f));
        m_InputTransform = CGAffineTransformScale(m_InputTransform, 1.0f, -1.0f);
        m_InputTransform = CGAffineTransformTranslate(m_InputTransform, -dispSize.width, -dispSize.height);

        [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
    }
    else
    {
        m_Transform = CGAffineTransformMakeTranslation(0.0f, dispSize.height);    // For skyscraper
        m_Transform = CGAffineTransformScale(m_Transform, 1.0f, -1.0f);

        m_InputTransform = CGAffineTransformMakeTranslation(0.0f, dispSize.height);
        m_InputTransform = CGAffineTransformScale(m_InputTransform, 1.0f, -1.0f);
    }

    [self setupControllerMappings];

    return self;
}

- (void)setupControllerMappings
{
    std::map<iCadeState, JPButton> mat_mapping;

    mat_mapping[iCadeButtonG] = kJoyButtonExit;
    mat_mapping[iCadeJoystickUp] = kJoyButtonUp;
    mat_mapping[iCadeJoystickDown] = kJoyButtonDown;
    mat_mapping[iCadeJoystickLeft] = kJoyButtonLeft;
    mat_mapping[iCadeJoystickRight] = kJoyButtonRight;
    mappings_.insert(std::make_pair("dance_mat", mat_mapping));

    std::map<iCadeState, JPButton> icade_arcade_mapping;

    icade_arcade_mapping[iCadeButtonG] = kJoyButtonExit;
    icade_arcade_mapping[iCadeButtonF] = kJoyButtonUp;
    icade_arcade_mapping[iCadeJoystickUp] = kJoyButtonUp;
    icade_arcade_mapping[iCadeButtonD] = kJoyButtonDown;
    icade_arcade_mapping[iCadeJoystickDown] = kJoyButtonDown;
    icade_arcade_mapping[iCadeButtonB] = kJoyButtonLeft;
    icade_arcade_mapping[iCadeJoystickLeft] = kJoyButtonLeft;
    icade_arcade_mapping[iCadeButtonH] = kJoyButtonRight;
    icade_arcade_mapping[iCadeJoystickRight] = kJoyButtonRight;
    mappings_.insert(std::make_pair("icade_arcade", icade_arcade_mapping));

    std::map<iCadeState, JPButton> icade_mobile_mapping;

    icade_mobile_mapping[iCadeButtonG] = kJoyButtonExit;
    icade_mobile_mapping[iCadeButtonD] = kJoyButtonUp;
    icade_mobile_mapping[iCadeJoystickUp] = kJoyButtonUp;
    icade_mobile_mapping[iCadeButtonC] = kJoyButtonDown;
    icade_mobile_mapping[iCadeJoystickDown] = kJoyButtonDown;
    icade_mobile_mapping[iCadeButtonA] = kJoyButtonLeft;
    icade_mobile_mapping[iCadeJoystickLeft] = kJoyButtonLeft;
    icade_mobile_mapping[iCadeButtonB] = kJoyButtonRight;
    icade_mobile_mapping[iCadeJoystickRight] = kJoyButtonRight;
    mappings_.insert(std::make_pair("icade_mobile", icade_mobile_mapping));

    std::map<iCadeState, JPButton> icp_mapping;

    icp_mapping[iCadeButtonG] = kJoyButtonExit;
    icp_mapping[iCadeButtonD] = kJoyButtonUp;
    icp_mapping[iCadeJoystickUp] = kJoyButtonUp;
    icp_mapping[iCadeButtonC] = kJoyButtonDown;
    icp_mapping[iCadeJoystickDown] = kJoyButtonDown;
    icp_mapping[iCadeButtonA] = kJoyButtonLeft;
    icp_mapping[iCadeJoystickLeft] = kJoyButtonLeft;
    icp_mapping[iCadeButtonB] = kJoyButtonRight;
    icp_mapping[iCadeJoystickRight] = kJoyButtonRight;
    mappings_.insert(std::make_pair("icp", icp_mapping));

    NSString *controller = [[SettingsEngine sharedInstance] getStringValue:@"controller"];
    [self setMappingWithName:controller];
}

- (void)switchToTapDB
{
    TMLog(@"Going to TapDB...");
    TapManiaAppDelegate *delegate = (TapManiaAppDelegate *) [UIApplication sharedApplication].delegate;
    [self.m_pWindow addSubview:delegate.tapdb.view];
}

- (void)switchToScreen:(Class)screenClass withMetrics:(NSString *)inMetrics
{
    [self registerObjectAtBegin:[[FadeTransition alloc] initFromScreen:m_pCurrentScreen toClass:screenClass withMetrics:inMetrics]];
}

- (void)switchToScreen:(Class)screenClass withMetrics:(NSString *)inMetrics usingTransition:(Class)transitionClass
{
    [self registerObjectAtBegin:[[transitionClass alloc] initFromScreen:m_pCurrentScreen toClass:screenClass withMetrics:inMetrics]];
}

- (void)switchToScreen:(Class)screenClass withMetrics:(NSString *)inMetrics usingTransition:(Class)transitionClass timeIn:(double)timeIn timeOut:(double)timeOut
{
    [self registerObjectAtBegin:[[transitionClass alloc] initFromScreen:m_pCurrentScreen toClass:screenClass withMetrics:inMetrics timeIn:timeIn timeOut:timeOut]];
}

- (void)addOverlay:(TMModalView *)modalView
{
    [self registerObjectAtEnd:modalView];
}

- (void)addOverlay:(Class)dialogClass withMetrics:(NSString *)inMetrics
{
    TMModalView *modalView = [[dialogClass alloc] initWithMetrics:inMetrics];
    [self registerObjectAtEnd:modalView];
}

- (void)removeOverlay:(TMModalView *)modalView
{
    [self deregisterObject:modalView];
    [modalView release];
}

- (void)registerObjectAtEnd:(NSObject *)obj
{
    [m_pGameRunLoop pushBackChild:obj];
}

- (void)registerObjectAtBegin:(NSObject *)obj
{
    [m_pGameRunLoop pushChild:obj];
}

- (void)deregisterObject:(NSObject *)obj
{
    [m_pGameRunLoop removeObject:obj];
}

- (void)deregisterAll
{
    [m_pGameRunLoop removeAllObjects];
}

- (void)deregisterCommandsForObject:(NSObject *)obj
{
    [m_pGameRunLoop removeCommandsForObject:obj];
}

- (void)pause
{
    [m_pGameRunLoop pause];
}

- (void)resume
{
    [m_pGameRunLoop resume];
}

- (void)setCurrentScreen:(TMScreen *)screenRenderer
{
    m_pCurrentScreen = screenRenderer;
}

- (void)releaseCurrentScreen
{
    if ( m_pCurrentScreen != nil )
    {
        [m_pCurrentScreen release];
    }
}

- (void)startGame
{
    // Alloc main run loop
    m_pGameRunLoop = [[TMRunLoop alloc] init];
    [m_pGameRunLoop delegate:self];

    // And run it
#if defined(NO_DISPLAY_LINK)
	[m_pGameRunLoop performSelectorOnMainThread:@selector(run) withObject:nil waitUntilDone:NO];
#else
    [m_pGameRunLoop performSelectorOnMainThread:@selector(run) withObject:nil waitUntilDone:YES];
#endif

    // Initialize social features
    [[GameCenterManager sharedInstance] authenticateUser];

    BROADCAST_MESSAGE(kApplicationStartedMessage, nil);
}

- (void)setMappingWithName:(NSString *)name
{
    std::map<std::string, std::map<iCadeState, JPButton> >::iterator it = mappings_.find(name.UTF8String);
    if(it != mappings_.end())
    {
        TMLog(@"Setting mapping with name %@", name);
        current_mapping_ = it->second;
    }
}

- (void)toggleAds:(BOOL)onOff
{
#ifdef ENABLE_ADWHIRL
    if (!onOff)
    {
        [m_pAdsView removeFromSuperview];
        [m_pAdsView ignoreNewAdRequests];
        [m_pAdsView ignoreAutoRefreshTimer];

    } else
    {
        [m_pAdsView doNotIgnoreAutoRefreshTimer];
        [m_pAdsView doNotIgnoreNewAdRequests];

        [m_pGlView addSubview:m_pAdsView];
        [m_pAdsView requestFreshAd];
    }
#endif
}

- (JoyPad *)enableJoyPad
{
    [m_pJoyPad reset];
    [[InputEngine sharedInstance] subscribe:m_pJoyPad];
    return m_pJoyPad;
}

- (void)disableJoyPad
{
    [[InputEngine sharedInstance] unsubscribe:m_pJoyPad];
}

/* Run loop delegate work */
- (void)runLoopInitHook
{
    TMLog(@"Init game run loop...");

    // Load up graphics system
    CGRect rect = [[UIScreen mainScreen] bounds];

    // Setup window
    m_pWindow = ((TapManiaAppDelegate *) [UIApplication sharedApplication].delegate).rootView;

    // Init opengl
    if ( g_pGameState->m_bLandscape )
    {
        CGSize s = [DisplayUtil getDeviceDisplaySize];
        m_pGlView = [[EAGLView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, s.height, s.width)];

        m_pGlView.transform = CGAffineTransformIdentity;
        m_pGlView.transform = CGAffineTransformMakeRotation(DEGTORAD(-90.0f));
        m_pGlView.center = CGPointMake(s.width / 2.0f, s.height / 2.0f);
    }
    else
    {
        CGSize s = [DisplayUtil getDeviceDisplaySize];
        if ( [DisplayUtil isRetina] )
        {
            m_pGlView = [[EAGLView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, s.width / 2, s.height / 2)];
        }
        else
        {
            m_pGlView = [[EAGLView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, s.width, s.height)];
        }
    }

    m_pGlView.multipleTouchEnabled = YES;

    // Init sound system and set the master volume from settings
    [[TMSoundEngine sharedInstance] setMasterVolume:[[SettingsEngine sharedInstance] getFloatValue:@"sound"]];
    [[TMSoundEngine sharedInstance] setEffectsVolume:[[SettingsEngine sharedInstance] getFloatValue:@"effectssound"]];
    [[TMSoundEngine sharedInstance] start];

    // Load theme graphics, sounds, fonts, etc.
    [[ThemeManager sharedInstance] selectTheme:[[SettingsEngine sharedInstance] getStringValue:@"theme"]];
    [[ThemeManager sharedInstance] selectNoteskin:[[SettingsEngine sharedInstance] getStringValue:@"noteskin"]];

    // Init global joypad
    m_pJoyPad = [[JoyPad alloc] init];
    self.iCadeResponder = nil;

    // Set up OpenGL projection matrix
    glMatrixMode(GL_PROJECTION);

    {
        int width = rect.size.width, height = rect.size.height;
        if ( g_pGameState->m_bLandscape )
        {
            int temp = width;
            width = height;
            height = temp;
        }
        if ( [DisplayUtil isRetina] )
        {
            glOrthof(0, width * 2, 0, height * 2, -1000, 1000);    // large depth so that rotated objects aren't clipped
        }
        else
        {
            glOrthof(0, width, 0, height, -1000, 1000);    // large depth so that rotated objects aren't clipped
        }
    }

    glMatrixMode(GL_MODELVIEW);

    // Initialize OpenGL states
    glDisable(GL_DEPTH_TEST);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_TEXTURE_2D);
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);    // multiply current color and texture color
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);

    glLoadIdentity();
    glClearColor(0, 0, 0, 1.0f);

    // Clear
    glClear(GL_COLOR_BUFFER_BIT);

    // No lighting/depth testing
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_LIGHTING);

    // Add the gl view to our main window
    [m_pWindow addSubview:m_pGlView];

#ifdef ENABLE_ADWHIRL
    // Create the AdWhirl thing
    m_pAdsView = [[AdWhirlView requestAdWhirlViewWithDelegate:[TapMania sharedInstance]] retain];
    m_pAdsView.clipsToBounds = YES;

    [m_pGlView addSubview:m_pAdsView];
    TMLog(@"Added the AdWhirl view.");
#endif // ENABLE_ADWHIRL

    TMLog(@"Done initializing opengl");
}

- (void)runLoopInitializedNotification
{
    // Show FPS in debug mode only. FPS rendering slows things a lot.
#ifdef DEBUG
    [[TapMania sharedInstance] registerObjectAtEnd:[[FPS alloc] init]];    // FPS drawing
#endif

    // Will start with song loader
    [[TapMania sharedInstance] switchToScreen:[SongsCacheLoaderRenderer class] withMetrics:@"SongsCacheLoader" usingTransition:[FadeTransition class] timeIn:0.0f timeOut:0.5f];

    TMLog(@"Game run loop initialized...");

    // Finally remove the loading screen
    [[m_pWindow.subviews objectAtIndex:0] removeFromSuperview];
}

- (void)runLoopBeforeHook:(float)fDelta
{
#ifdef NO_DISPLAY_LINK
	// We must let the system handle all the events too
	while( CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.009, FALSE) == kCFRunLoopRunHandledSource);
#endif
}

- (void)runLoopAfterHook:(float)fDelta
{
    // Must swap buffer after drawing
    [self.glView swapBuffers];
}

#pragma mark ARRollerDelegate required delegate method implementation
#ifdef ENABLE_ADWHIRL
- (NSString *)adWhirlApplicationKey
{
    // 0.3 version for os 4
    return @"2f024b7d377747de8dadf20ef4f22fdd";
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return ((TapManiaAppDelegate *) [UIApplication sharedApplication].delegate).rootController;
}

- (void)adWhirlDidReceiveAd:(AdWhirlView *)adView
{
    [UIView beginAnimations:@"AdWhirlDelegate.adWhirlDidReceiveAd:"
                    context:nil];

    [UIView setAnimationDuration:0.7];

    CGSize adSize = [adView actualAdSize];
    CGRect newFrame = adView.frame;

    newFrame.size = adSize;
    newFrame.origin.x = (self.glView.bounds.size.width - adSize.width) / 2;
    newFrame.origin.y = self.glView.bounds.size.height - adSize.height;

    adView.frame = newFrame;

    [UIView commitAnimations];
}
#endif // ENABLE_ADWHIRL

#pragma mark Singleton stuff
+ (TapMania *)sharedInstance
{
    @synchronized ( self )
    {
        if ( sharedTapManiaDelegate == nil )
        {
            [[self alloc] init];
        }
    }
    return sharedTapManiaDelegate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized ( self )
    {
        if ( sharedTapManiaDelegate == nil )
        {
            sharedTapManiaDelegate = [super allocWithZone:zone];
            return sharedTapManiaDelegate;
        }
    }

    return nil;
}


- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release
{
    // NOTHING
}

- (id)autorelease
{
    return self;
}

- (void)hardwareControllerButtonDown:(iCadeState)button
{
    std::map<iCadeState, JPButton>::iterator it = current_mapping_.find(button);
    if ( it != current_mapping_.end() )
    {
        if ( self.iCadeResponder )
        {
            [self.iCadeResponder buttonDown:it->second];
        }
        else
        {
            [[TapMania sharedInstance].joyPad setState:YES forButton:it->second];
        }
    }
}

- (void)hardwareControllerButtonUp:(iCadeState)button
{
    std::map<iCadeState, JPButton>::iterator it = current_mapping_.find(button);
    if ( it != current_mapping_.end() )
    {
        if ( self.iCadeResponder )
        {
            [self.iCadeResponder buttonUp:it->second];
        }
        else
        {
            [[TapMania sharedInstance].joyPad setState:NO forButton:it->second];
        }
    }
}
@end
