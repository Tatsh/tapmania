//
//  OptionsMenuRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TapMania.h"
#import "InputEngine.h"
#import "EAGLView.h"
#import "ThemeManager.h"
#import "Texture2D.h"
#import "SettingsEngine.h"

#import "MenuItem.h"
#import "ZoomEffect.h"
#import "SlideEffect.h"

#import "QuadTransition.h"

#import "TogglerItem.h"
#import "Label.h"
#import "Slider.h"

#import "OptionsMenuRenderer.h"
#import "MainMenuRenderer.h"
#import "PadConfigRenderer.h"
#import "SongManagerRenderer.h"

#import "TMSoundEngine.h"

@interface OptionsMenuRenderer (InputHandling)
- (void) joyPadButtonHit;
- (void) songManagerButtonHit;
- (void) backButtonHit;
- (void) soundSliderChanged;
- (void) themeTogglerChanged;
- (void) noteSkinTogglerChanged;
- (void) visiblePadTogglerChanged;
- (void) fingerTrackingTogglerChanged;
@end

@implementation OptionsMenuRenderer

/* TMTransitionSupport methods */
- (void) setupForTransition {
	[super setupForTransition];
	
	// Cache metrics
	mt_PadConfigButton =		RECT_METRIC(@"OptionsMenu PadConfigButton");
	mt_SongManagerButton =		RECT_METRIC(@"OptionsMenu SongManagerButton");
	mt_BackButton =				RECT_METRIC(@"OptionsMenu BackButton");
	mt_NoteSkinLabel =			RECT_METRIC(@"OptionsMenu NoteSkinLabel");
	mt_NoteSkinToggler =		RECT_METRIC(@"OptionsMenu NoteSkinToggler");
	mt_ThemeLabel =				RECT_METRIC(@"OptionsMenu ThemeLabel");
	mt_ThemeToggler =			RECT_METRIC(@"OptionsMenu ThemeToggler");
	mt_SoundLabel =				RECT_METRIC(@"OptionsMenu SoundLabel");
	mt_SoundSlider =			RECT_METRIC(@"OptionsMenu SoundSlider");
	mt_FingerTrackingLabel =	RECT_METRIC(@"OptionsMenu FingerTrackingLabel");
	mt_VisiblePadLabel =		RECT_METRIC(@"OptionsMenu VisiblePadLabel");
	mt_FingerTrackingToggler =	RECT_METRIC(@"OptionsMenu FingerTrackingToggler");
	mt_VisiblePadToggler =		RECT_METRIC(@"OptionsMenu VisiblePadToggler");
	
	// Preload all required graphics
	t_BG =						TEXTURE(@"OptionsMenu Background");
	
	// No item selected by default
	m_nSelectedMenu = (OptionsMenuItem)-1;
	m_nState = kOptionsMenuState_Ready;
	m_dAnimationTime = 0.0;	

	// Register labels
	[self pushBackChild:[[Label alloc] initWithTitle:@"Sound:" andShape:mt_SoundLabel]];
	[self pushBackChild:[[Label alloc] initWithTitle:@"Theme:" andShape:mt_ThemeLabel]];
	[self pushBackChild:[[Label alloc] initWithTitle:@"Noteskin:" andShape:mt_NoteSkinLabel]];
	[self pushBackChild:[[Label alloc] initWithTitle:@"Autotrack:" andShape:mt_FingerTrackingLabel]];
	[self pushBackChild:[[Label alloc] initWithTitle:@"VisPad:" andShape:mt_VisiblePadLabel]];

	// Register menu items 
	m_pSoundSlider =	
	[[ZoomEffect alloc] initWithRenderable:[[Slider alloc] initWithShape:mt_SoundSlider 
						andValue:[[TMSoundEngine sharedInstance] getMasterVolume]]];

	// Finger tracking
	m_pFingerTrackToggler =	
	[[ZoomEffect alloc] initWithRenderable:	
	 [[TogglerItem alloc] initWithShape:mt_FingerTrackingToggler]];
	
	[m_pFingerTrackToggler addItem:[NSNumber numberWithBool:YES] withTitle:@"Enabled"];
	[m_pFingerTrackToggler addItem:[NSNumber numberWithBool:NO] withTitle:@"Disabled"];
	
	BOOL fingerTrack = [[SettingsEngine sharedInstance] getBoolValue:@"autotrack"];
	int iFingerTrack = [m_pFingerTrackToggler findIndexByValue:[NSNumber numberWithBool:fingerTrack]];
	iFingerTrack = iFingerTrack == -1 ? 1 : iFingerTrack;
	
	[m_pFingerTrackToggler selectItemAtIndex:iFingerTrack];	
	
	// PAD visibility
	m_pVisPadToggler =	
	[[ZoomEffect alloc] initWithRenderable:	
	 [[TogglerItem alloc] initWithShape:mt_VisiblePadToggler]];
	
	[m_pVisPadToggler addItem:[NSNumber numberWithBool:YES] withTitle:@"Enabled"];
	[m_pVisPadToggler addItem:[NSNumber numberWithBool:NO] withTitle:@"Disabled"];

	BOOL visPad = [[SettingsEngine sharedInstance] getBoolValue:@"vispad"];
	int iPad = [m_pVisPadToggler findIndexByValue:[NSNumber numberWithBool:visPad]];
	iPad = iPad == -1 ? 1 : iPad;
	
	[m_pVisPadToggler selectItemAtIndex:iPad];		
		
	// Theme selection
	m_pThemeToggler = 
	[[ZoomEffect alloc] initWithRenderable:	
	 [[TogglerItem alloc] initWithShape:mt_ThemeToggler]];
	
	// Add all themes to the toggler list
	for (NSString* themeName in [[ThemeManager sharedInstance] themeList]) {
		[m_pThemeToggler addItem:themeName withTitle:themeName];	
	}
	
	// Preselect the one from config
	NSString* theme = [[SettingsEngine sharedInstance] getStringValue:@"theme"];
	int iTheme = [m_pThemeToggler findIndexByValue:theme];
	iTheme = iTheme == -1 ? 0 : iTheme;
	
	[m_pThemeToggler selectItemAtIndex:iTheme];	
	
	// NoteSkin selection
	m_pNoteSkinToggler = 		
	[[ZoomEffect alloc] initWithRenderable:	
	 [[TogglerItem alloc] initWithShape:mt_NoteSkinToggler]];
	
	// Add all noteskins to the toggler list
	for (NSString* skinName in [[ThemeManager sharedInstance] noteskinList]) {
		[m_pNoteSkinToggler addItem:skinName withTitle:skinName];	
	}
	
	// Preselect the one from config
	NSString* noteskin = [[SettingsEngine sharedInstance] getStringValue:@"noteskin"];
	int iSkin = [m_pNoteSkinToggler findIndexByValue:noteskin];
	iSkin = iSkin == -1 ? 0 : iSkin;
	
	[m_pNoteSkinToggler selectItemAtIndex:iSkin];	
	
	MenuItem* padConfigButton = 
	 [[ZoomEffect alloc] initWithRenderable:	
	  [[MenuItem alloc] initWithTitle:@"Pad config" andShape:mt_PadConfigButton]];

	MenuItem* songManagerButton = 
	[[ZoomEffect alloc] initWithRenderable:	
	 [[MenuItem alloc] initWithTitle:@"Song manager" andShape:mt_SongManagerButton]];
	
	m_pBackButton = 
	[[SlideEffect alloc] initWithRenderable:
	 [[ZoomEffect alloc] initWithRenderable:	
	  [[MenuItem alloc] initWithTitle:@"Back" andShape:mt_BackButton]]];
	
	[(SlideEffect*)m_pBackButton destination: CGPointMake(mt_BackButton.origin.x, 480+mt_BackButton.origin.y)];
	[(SlideEffect*)m_pBackButton effectTime: 0.4f];
	
	// Setup action handlers
	[songManagerButton setActionHandler:@selector(songManagerButtonHit) receiver:self];
	[padConfigButton setActionHandler:@selector(joyPadButtonHit) receiver:self];
	[m_pBackButton setActionHandler:@selector(backButtonHit) receiver:self];
	[m_pFingerTrackToggler setActionHandler:@selector(fingerTrackingTogglerChanged) receiver:self];
	[m_pVisPadToggler setActionHandler:@selector(visiblePadTogglerChanged) receiver:self];
	[m_pThemeToggler setActionHandler:@selector(themeTogglerChanged) receiver:self];
	[m_pNoteSkinToggler setActionHandler:@selector(noteSkinTogglerChanged) receiver:self];
	[m_pSoundSlider setChangedActionHandler:@selector(soundSliderChanged) receiver:self];	
	
	// Add controls
	[self pushBackControl:m_pFingerTrackToggler];
	[self pushBackControl:m_pVisPadToggler];
	[self pushBackControl:m_pThemeToggler];
	[self pushBackControl:m_pNoteSkinToggler];
	[self pushBackControl:m_pSoundSlider];
	
	[self pushBackControl:songManagerButton];
	[self pushBackControl:padConfigButton];
	[self pushBackControl:m_pBackButton];	
	
	// Temporarily remove ads
	[[TapMania sharedInstance] toggleAds:NO];
}

- (void) deinitOnTransition {
	[super deinitOnTransition];
	
	// Get ads back to place
	[[TapMania sharedInstance] toggleAds:YES];
}

- (void)render:(float) fDelta {
	CGRect bounds = [TapMania sharedInstance].glView.bounds;
	
	// Draw menu background
	[t_BG drawInRect:bounds];
	
	// Draw children
	[super render:fDelta];
}	

/* TMLogicUpdater stuff */
- (void) update:(float)fDelta {
	[super update:fDelta];
	
	if(m_nState == kOptionsMenuState_Ready) {
		
		if(m_nSelectedMenu == kOptionsMenuItem_Back) {
			TMLog(@"Getting back to main menu....");		
			m_nState = kOptionsMenuState_AnimatingOut;
		} else if(m_nSelectedMenu == kOptionsMenuItem_JoyPad) {
			[[TapMania sharedInstance] switchToScreen:[[PadConfigRenderer alloc] init]];

			m_nState = kOptionsMenuState_None;	// Do nothing more
			return;
		} else if(m_nSelectedMenu == kOptionsMenuItem_SongManager) {
			[[TapMania sharedInstance] switchToScreen:[[SongManagerRenderer alloc] init]];
			
			m_nState = kOptionsMenuState_None;	// Do nothing more
			return;
		}
		
	} else if(m_nState == kOptionsMenuState_Finished) {
		
		if(m_nSelectedMenu == kOptionsMenuItem_Back) {
			[[TapMania sharedInstance] switchToScreen:[[MainMenuRenderer alloc] init] usingTransition:[QuadTransition class]];
		}
		
		m_nState = kOptionsMenuState_None;	// Do nothing more
		
	} else if(m_nState == kOptionsMenuState_AnimatingOut) {		
		
		if([(SlideEffect*)m_pBackButton isFinished]) {
			m_nState = kOptionsMenuState_Finished;
			return;
		}
		
		// Start stuff with timeouts
		if(![(SlideEffect*)m_pBackButton isFinished] && 
		   ![(SlideEffect*)m_pBackButton isTweening])
		{			
			[(SlideEffect*)m_pBackButton startTweening];			
		} 
		
		m_dAnimationTime += fDelta;
	}
	
}

/* Input handlers */
- (void) joyPadButtonHit {
	m_nSelectedMenu = kOptionsMenuItem_JoyPad;
}

- (void) songManagerButtonHit {
	m_nSelectedMenu = kOptionsMenuItem_SongManager;
}

- (void) backButtonHit {
	m_nSelectedMenu = kOptionsMenuItem_Back;
	
	// Hack. This is slow so we do this on exit... save the sound setting only once (FIXME!!!!)
	[[SettingsEngine sharedInstance] setFloatValue:	[[TMSoundEngine sharedInstance] getMasterVolume] forKey:@"sound"];
}

- (void) soundSliderChanged {
	float value = [m_pSoundSlider currentValue];
	[[TMSoundEngine sharedInstance] setMasterVolume:value];
}

- (void) themeTogglerChanged {
	[[SettingsEngine sharedInstance] setStringValue:[[m_pThemeToggler getCurrent] m_pValue] forKey:@"theme"];
}

- (void) noteSkinTogglerChanged {
	[[SettingsEngine sharedInstance] setStringValue:[[m_pNoteSkinToggler getCurrent] m_pValue] forKey:@"noteskin"];
}

- (void) visiblePadTogglerChanged {
	NSNumber* numVal = (NSNumber*)[[m_pVisPadToggler getCurrent] m_pValue];
	BOOL val = [numVal boolValue];
	[[SettingsEngine sharedInstance] setBoolValue:val forKey:@"vispad"];
}

- (void) fingerTrackingTogglerChanged {
	NSNumber* numVal = (NSNumber*)[[m_pFingerTrackToggler getCurrent] m_pValue];
	BOOL val = [numVal boolValue];
	
	[[SettingsEngine sharedInstance] setBoolValue:val forKey:@"autotrack"];	
	[[[TapMania sharedInstance] joyPad] setM_bAutoTrackEnabled:val];
}

@end
