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
#import "SoundEngine.h"

#import "MenuItem.h"
#import "ZoomEffect.h"
#import "SlideEffect.h"

#import "QuadTransition.h"

#import "TogglerItem.h"
#import "Label.h"
#import "Slider.h"

#import "OptionsMenuRenderer.h"
#import "MainMenuRenderer.h"

@interface OptionsMenuRenderer (InputHandling)
- (void) backButtonHit;
- (void) soundSliderChanged;
@end

@implementation OptionsMenuRenderer

int mt_BackButtonY, mt_MenuButtonsX;
int mt_MenuButtonsWidth, mt_MenuButtonsHeight;
Texture2D *t_BG;

- (void) dealloc {
	// Release menu items
	[m_pOptionsMenuItems[kOptionsMenuItem_SoundMaster] release];
	[m_pOptionsMenuItems[kOptionsMenuItem_Back] release];
	[m_pOptionsMenuItems[kOptionsMenuItem_Theme] release];
	[m_pOptionsMenuItems[kOptionsMenuItem_NoteSkin] release];
	
	[m_pLabels[kOptionsLabel_SoundMaster] release];
	[m_pLabels[kOptionsLabel_Theme] release];
	[m_pLabels[kOptionsLabel_NoteSkin] release];
	
	[super dealloc];
}

/* TMTransitionSupport methods */
- (void) setupForTransition {
	// Cache metrics
	mt_BackButtonY = [[ThemeManager sharedInstance] intMetric:@"OptionsMenu BackButtonY"];
	mt_MenuButtonsX = [[ThemeManager sharedInstance] intMetric:@"OptionsMenu ButtonsX"];	
	mt_MenuButtonsWidth = [[ThemeManager sharedInstance] intMetric:@"OptionsMenu ButtonsWidth"];
	mt_MenuButtonsHeight = [[ThemeManager sharedInstance] intMetric:@"OptionsMenu ButtonsHeight"];
	
	// Preload all required graphics
	t_BG = [[ThemeManager sharedInstance] texture:@"OptionsMenu Background"];
	
	// No item selected by default
	m_nSelectedMenu = -1;
	m_nState = kOptionsMenuState_Ready;
	m_dAnimationTime = 0.0;	
	
	m_pLabels[kOptionsLabel_SoundMaster] = [[Label alloc] initWithTitle:@"Sound:" andShape:CGRectMake(20.0f, 90.0f, 70.0f, 46.0f)];
	m_pLabels[kOptionsLabel_Theme] = [[Label alloc] initWithTitle:@"Theme:" andShape:CGRectMake(20.0f, 150.0f, 70.0f, 46.0f)];
	m_pLabels[kOptionsLabel_NoteSkin] = [[Label alloc] initWithTitle:@"Noteskin:" andShape:CGRectMake(20.0f, 200.0f, 80.0f, 46.0f)];
	
	// Register menu items
	m_pOptionsMenuItems[kOptionsMenuItem_SoundMaster] =	
	[[ZoomEffect alloc] initWithRenderable:	
	 [[Slider alloc] initWithShape:CGRectMake(110.0f, 90.0f, 190.0f, 46.0f) andValue:SoundEngine_GetMasterVolume()]];
	
	// Theme selection
	m_pOptionsMenuItems[kOptionsMenuItem_Theme] = 
	[[ZoomEffect alloc] initWithRenderable:	
	 [[TogglerItem alloc] initWithShape:CGRectMake(110.0f, 150.0f, 190.0f, 46.0f)]];
	
	// Add all themes to the toggler list
	for (NSString* themeName in [[ThemeManager sharedInstance] themeList]) {
		[(TogglerItem*)m_pOptionsMenuItems[kOptionsMenuItem_Theme] addItem:themeName withTitle:themeName];	
	}
	
	// Preselect the one from config
	NSString* theme = [[SettingsEngine sharedInstance] getStringValue:@"theme"];
	int iTheme = [(TogglerItem*)m_pOptionsMenuItems[kOptionsMenuItem_Theme] findIndexByValue:theme];
	iTheme = iTheme == -1 ? 0 : iTheme;
	
	[(TogglerItem*)m_pOptionsMenuItems[kOptionsMenuItem_Theme] selectItemAtIndex:iTheme];	
	
	// NoteSkin selection
	m_pOptionsMenuItems[kOptionsMenuItem_NoteSkin] = 		
	[[ZoomEffect alloc] initWithRenderable:	
	 [[TogglerItem alloc] initWithShape:CGRectMake(110.0f, 200.0f, 190.0f, 46.0f)]];
	
	// Add all noteskins to the toggler list
	for (NSString* skinName in [[ThemeManager sharedInstance] noteskinList]) {
		[(TogglerItem*)m_pOptionsMenuItems[kOptionsMenuItem_NoteSkin] addItem:skinName withTitle:skinName];	
	}
	
	// Preselect the one from config
	NSString* noteskin = [[SettingsEngine sharedInstance] getStringValue:@"noteskin"];
	int iSkin = [(TogglerItem*)m_pOptionsMenuItems[kOptionsMenuItem_NoteSkin] findIndexByValue:noteskin];
	iSkin = iSkin == -1 ? 0 : iSkin;
	
	[(TogglerItem*)m_pOptionsMenuItems[kOptionsMenuItem_NoteSkin] selectItemAtIndex:iSkin];	
	
	
	m_pOptionsMenuItems[kOptionsMenuItem_Back] = 
	[[SlideEffect alloc] initWithRenderable:
	 [[ZoomEffect alloc] initWithRenderable:	
	  [[MenuItem alloc] initWithTitle:@"Back" andShape:CGRectMake(mt_MenuButtonsX, mt_BackButtonY, mt_MenuButtonsWidth, mt_MenuButtonsHeight)]]];
	
	[(SlideEffect*)(m_pOptionsMenuItems[kOptionsMenuItem_Back]) destination: CGPointMake(mt_MenuButtonsX, 480+mt_MenuButtonsHeight)];
	[(SlideEffect*)(m_pOptionsMenuItems[kOptionsMenuItem_Back]) effectTime: 0.4f];
	
	[m_pOptionsMenuItems[kOptionsMenuItem_Back] setActionHandler:@selector(backButtonHit) receiver:self];
	[m_pOptionsMenuItems[kOptionsMenuItem_Theme] setActionHandler:@selector(themeTogglerChanged) receiver:self];
	[m_pOptionsMenuItems[kOptionsMenuItem_NoteSkin] setActionHandler:@selector(noteSkinTogglerChanged) receiver:self];
	[m_pOptionsMenuItems[kOptionsMenuItem_SoundMaster] setChangedActionHandler:@selector(soundSliderChanged) receiver:self];	
	
	// Add the menu items to the render loop with lower priority
	[[TapMania sharedInstance] registerObject:m_pOptionsMenuItems[kOptionsMenuItem_SoundMaster] withPriority:kRunLoopPriority_NormalUpper];
	[[TapMania sharedInstance] registerObject:m_pOptionsMenuItems[kOptionsMenuItem_Theme] withPriority:kRunLoopPriority_NormalUpper];
	[[TapMania sharedInstance] registerObject:m_pOptionsMenuItems[kOptionsMenuItem_NoteSkin] withPriority:kRunLoopPriority_NormalUpper];
	[[TapMania sharedInstance] registerObject:m_pOptionsMenuItems[kOptionsMenuItem_Back] withPriority:kRunLoopPriority_NormalUpper];
	
	[[TapMania sharedInstance] registerObject:m_pLabels[kOptionsLabel_SoundMaster] withPriority:kRunLoopPriority_NormalUpper];
	[[TapMania sharedInstance] registerObject:m_pLabels[kOptionsLabel_Theme] withPriority:kRunLoopPriority_NormalUpper];
	[[TapMania sharedInstance] registerObject:m_pLabels[kOptionsLabel_NoteSkin] withPriority:kRunLoopPriority_NormalUpper];
	
	// Subscribe for input events
	[[InputEngine sharedInstance] subscribe:m_pOptionsMenuItems[kOptionsMenuItem_SoundMaster]];
	[[InputEngine sharedInstance] subscribe:m_pOptionsMenuItems[kOptionsMenuItem_Theme]];
	[[InputEngine sharedInstance] subscribe:m_pOptionsMenuItems[kOptionsMenuItem_NoteSkin]];
	[[InputEngine sharedInstance] subscribe:m_pOptionsMenuItems[kOptionsMenuItem_Back]];
}

- (void) deinitOnTransition {
	// Unsubscribe from input events
	[[InputEngine sharedInstance] unsubscribe:m_pOptionsMenuItems[kOptionsMenuItem_SoundMaster]];
	[[InputEngine sharedInstance] unsubscribe:m_pOptionsMenuItems[kOptionsMenuItem_Theme]];
	[[InputEngine sharedInstance] unsubscribe:m_pOptionsMenuItems[kOptionsMenuItem_NoteSkin]];
	[[InputEngine sharedInstance] unsubscribe:m_pOptionsMenuItems[kOptionsMenuItem_Back]];
		
	// Remove the menu items from the render loop
	[[TapMania sharedInstance] deregisterObject:m_pOptionsMenuItems[kOptionsMenuItem_SoundMaster]];
	[[TapMania sharedInstance] deregisterObject:m_pOptionsMenuItems[kOptionsMenuItem_Theme]];
	[[TapMania sharedInstance] deregisterObject:m_pOptionsMenuItems[kOptionsMenuItem_NoteSkin]];
	[[TapMania sharedInstance] deregisterObject:m_pOptionsMenuItems[kOptionsMenuItem_Back]];
	
	[[TapMania sharedInstance] deregisterObject:m_pLabels[kOptionsLabel_SoundMaster]];
	[[TapMania sharedInstance] deregisterObject:m_pLabels[kOptionsLabel_Theme]];
	[[TapMania sharedInstance] deregisterObject:m_pLabels[kOptionsLabel_NoteSkin]];
}

- (void)render:(float) fDelta {
	CGRect bounds = [TapMania sharedInstance].glView.bounds;
	
	// Draw menu background
	[t_BG drawInRect:bounds];
	
	// NOTE: Items will be rendered by it self	
}	

/* TMLogicUpdater stuff */
- (void) update:(float)fDelta {
	if(m_nState == kOptionsMenuState_Ready) {
		
		if(m_nSelectedMenu == kOptionsMenuItem_Back) {
			TMLog(@"Getting back to main menu....");		
			m_nState = kOptionsMenuState_AnimatingOut;
		}
		
	} else if(m_nState == kOptionsMenuState_Finished) {
		
		if(m_nSelectedMenu == kOptionsMenuItem_Back) {
			[[TapMania sharedInstance] switchToScreen:[[MainMenuRenderer alloc] init] usingTransition:[QuadTransition class]];
		}
		
		m_nState = kOptionsMenuState_None;	// Do nothing more
		
	} else if(m_nState == kOptionsMenuState_AnimatingOut) {		
		
		if([(SlideEffect*)m_pOptionsMenuItems[kOptionsMenuItem_Back] isFinished]) {
			m_nState = kMainMenuState_Finished;
			return;
		}
		
		// Start stuff with timeouts
		if(![(SlideEffect*)m_pOptionsMenuItems[kOptionsMenuItem_Back] isFinished] && 
		   ![(SlideEffect*)m_pOptionsMenuItems[kOptionsMenuItem_Back] isTweening])
		{			
			[(SlideEffect*)m_pOptionsMenuItems[kOptionsMenuItem_Back] startTweening];			
		} 
		
		m_dAnimationTime += fDelta;
	}
	
}

/* Input handlers */
- (void) backButtonHit {
	m_nSelectedMenu = kOptionsMenuItem_Back;
	
	// Hack. This is slow so we do this on exit... save the sound setting only once
	[[SettingsEngine sharedInstance] setFloatValue:SoundEngine_GetMasterVolume() forKey:@"sound"];
}

- (void) soundSliderChanged {
	float value = [(Slider*)m_pOptionsMenuItems[kOptionsMenuItem_SoundMaster] currentValue];
	SoundEngine_SetMasterVolume(value);
}

- (void) themeTogglerChanged {
	[[SettingsEngine sharedInstance] setStringValue:[[((TogglerItem*)m_pOptionsMenuItems[kOptionsMenuItem_Theme]) getCurrent] m_pValue] forKey:@"theme"];
}

- (void) noteSkinTogglerChanged {
	[[SettingsEngine sharedInstance] setStringValue:[[((TogglerItem*)m_pOptionsMenuItems[kOptionsMenuItem_NoteSkin]) getCurrent] m_pValue] forKey:@"noteskin"];
}

@end
