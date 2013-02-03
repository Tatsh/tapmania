//
//  $Id$
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

#import "TogglerItem.h"
#import "OptionsMenuRenderer.h"

#import "TMSoundEngine.h"
#import "Flurry.h"
#import "ICadeResponder.h"

@interface OptionsMenuRenderer (InputHandling)
- (void)themeTogglerChanged;

- (void)controllerMappingTogglerChanged;
@end

@implementation OptionsMenuRenderer

/* TMTransitionSupport methods */
- (void)setupForTransition
{
    [super setupForTransition];
	[Flurry logEvent:@"options_screen_enter"];

    // Register menu items
    // Theme selection
    m_pThemeToggler = [[TogglerItem alloc] initWithMetrics:@"OptionsMenu ThemeTogglerCustom"];

    // Add all themes to the toggler list
    for (NSString *themeName in [[ThemeManager sharedInstance] themeList])
    {
        [m_pThemeToggler addItem:themeName withTitle:themeName];
    }

    // Preselect the one from config
    NSString *theme = [[SettingsEngine sharedInstance] getStringValue:@"theme"];
    int iTheme = [m_pThemeToggler findIndexByValue:theme];
    iTheme = iTheme == -1 ? 0 : iTheme;

    [m_pThemeToggler selectItemAtIndex:iTheme];

    // Controller mapping selection
    m_pControllerMappingToggler = [[TogglerItem alloc] initWithMetrics:@"OptionsMenu ControllerMappingTogglerCustom"];

    [m_pControllerMappingToggler addItem:@"dance_mat" withTitle:@"All-Star Mat"];
    [m_pControllerMappingToggler addItem:@"icade_arcade" withTitle:@"iCade Arcade"];
    [m_pControllerMappingToggler addItem:@"icade_mobile" withTitle:@"iCade Mobile"];
    [m_pControllerMappingToggler addItem:@"icp" withTitle:@"iControlPad"];

    // Preselect the one from config
    NSString *controller = [[SettingsEngine sharedInstance] getStringValue:@"controller"];
    int iCntrl = [m_pControllerMappingToggler findIndexByValue:controller];
    iCntrl = iCntrl == -1 ? 0 : iCntrl;

    [m_pControllerMappingToggler selectItemAtIndex:iCntrl];

    // Setup action handlers
    [m_pThemeToggler setActionHandler:@selector(themeTogglerChanged) receiver:self];
    [m_pControllerMappingToggler setActionHandler:@selector(controllerMappingTogglerChanged) receiver:self];

    // Add controls
    [self pushBackControl:m_pThemeToggler];
    [self pushBackControl:m_pControllerMappingToggler];

    // Temporarily remove ads
	[[TapMania sharedInstance] toggleAds:NO];
}

- (void)deinitOnTransition
{
    [super deinitOnTransition];

    // Get ads back to place
	// [[TapMania sharedInstance] toggleAds:YES];
}

/* Input handlers */
- (void)themeTogglerChanged
{
    [[SettingsEngine sharedInstance] setStringValue:(NSString *) [[m_pThemeToggler getCurrent] m_pValue] forKey:@"theme"];
}

- (void)controllerMappingTogglerChanged
{
    NSString *name = (NSString *) [[m_pControllerMappingToggler getCurrent] m_pValue];
    [[SettingsEngine sharedInstance] setStringValue:name forKey:@"controller"];

    [[TapMania sharedInstance] setMappingWithName:name];
}

@end
