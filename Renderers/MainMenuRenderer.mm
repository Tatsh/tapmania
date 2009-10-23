//
//  MainMenuRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "MainMenuRenderer.h"
#import "MenuItem.h"
#import "Label.h"
#import "ImageButton.h"

#import "TMRunLoop.h"
#import "TMRenderable.h"

#import "EAGLView.h"
#import "InputEngine.h"
#import "TapMania.h"
#import "ThemeManager.h"
#import "Texture2D.h"
#import "SongsDirectoryCache.h"

#import "ZoomEffect.h"

#import "FontManager.h"
#import "Font.h"

#import "TMSoundEngine.h"
#import "TMSound.h"

#import "GameState.h"
#import "VersionInfo.h"

@interface MainMenuRenderer (InputHandling)
- (void) donateButtonHit;
@end

extern TMGameState* g_pGameState;

@implementation MainMenuRenderer

/* TMTransitionSupport methods */
- (void) setupForTransition {
	[super setupForTransition];
			
	// Preload all required graphics
	t_BG = TEXTURE(@"MainMenu Background");
	t_Donate = TEXTURE(@"Common Donate");
	
	// And sounds
	sr_BG = SOUND(@"MainMenu Music");
	
	// Create version and copyright
	[self pushBackChild:[[Label alloc] initWithTitle:TAPMANIA_VERSION_STRING fontSize:12.0f andShape:CGRectMake(212, 285, 80, 40)]];
	[self pushBackChild:[[Label alloc] initWithTitle:TAPMANIA_COPYRIGHT fontSize:12.0f andShape:CGRectMake(140, 10, 180, 20)]];
	
	// Create donation button
	ImageButton* donateButton = 
	[[ZoomEffect alloc] initWithRenderable:
		 [[ImageButton alloc] initWithTexture:t_Donate andShape:CGRectMake(3, 3, 62, 31)]];
	[self pushBackControl:donateButton];
	
	// Register menu items
	// Must disable the play button if empty catalogue
	/*
	if([SongsDirectoryCache sharedInstance].catalogueIsEmpty) {
		m_pPlayButton = 
		[[MenuItem alloc] initWithTitle:@"No Songs" andShape:RECT_METRIC(@"MainMenu PlayButton")];
		
		[m_pPlayButton disable];
	} else {
		
		m_pPlayButton = 
		 [[ZoomEffect alloc] initWithRenderable:
			 [[MenuItem alloc] initWithMetrics:@"MainMenu PlayButton"]];
	}

	[self pushBackControl:m_pPlayButton];
	
	m_pOptionsButton = 
	 [[ZoomEffect alloc] initWithRenderable:
	 [[MenuItem alloc] initWithMetrics:@"MainMenu OptionsButton"]];
	[self pushBackControl:m_pOptionsButton];
	
	m_pCreditsButton =
	 [[ZoomEffect alloc] initWithRenderable:
	  [[MenuItem alloc] initWithMetrics:@"MainMenu CreditsButton"]];
	[self pushBackControl:m_pCreditsButton];
	*/
	 
	// Setup input handlers
	[donateButton setActionHandler:@selector(donateButtonHit) receiver:self];	
		
	// Play music
	if( ! sr_BG.playing ) {
		[[TMSoundEngine sharedInstance] addToQueue:sr_BG];
	}
	
	// Get ads back to place
	[[TapMania sharedInstance] toggleAds:YES];	 
	
	// A little hack for the news popup. now it can raise if it has something
	g_pGameState->m_bPlayingGame = NO;
}

- (void) beforeTransition {
	[[InputEngine sharedInstance] disableDispatcher];
}

/* TMRenderable method */
- (void) render:(float)fDelta {
	CGRect bounds = [TapMania sharedInstance].glView.bounds;
	
	// Draw menu background
	[t_BG drawInRect:bounds];
	
	// Draw children
	[super render:fDelta];
}

/* Input handlers */
- (void) donateButtonHit {
	NSURL* url = [NSURL URLWithString:DONATE_URL];
	[[UIApplication sharedApplication] openURL:url];
}

@end
