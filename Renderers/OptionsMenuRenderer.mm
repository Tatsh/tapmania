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
// #import "FlurryAPI.h"

@interface OptionsMenuRenderer (InputHandling)
- (void)themeTogglerChanged;

- (void)noteSkinTogglerChanged;
@end

@implementation OptionsMenuRenderer

/* TMTransitionSupport methods */
- (void)setupForTransition
{
    [super setupForTransition];
//	[FlurryAPI logEvent:@"options_screen_enter"];

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

    // NoteSkin selection
    m_pNoteSkinToggler = [[TogglerItem alloc] initWithMetrics:@"OptionsMenu NoteSkinTogglerCustom"];

    // Add all noteskins to the toggler list
    for (NSString *skinName in [[ThemeManager sharedInstance] noteskinList])
    {
        [m_pNoteSkinToggler addItem:skinName withTitle:skinName];
    }

    // Preselect the one from config
    NSString *noteskin = [[SettingsEngine sharedInstance] getStringValue:@"noteskin"];
    int iSkin = [m_pNoteSkinToggler findIndexByValue:noteskin];
    iSkin = iSkin == -1 ? 0 : iSkin;

    [m_pNoteSkinToggler selectItemAtIndex:iSkin];

    // Setup action handlers
    [m_pThemeToggler setActionHandler:@selector(themeTogglerChanged) receiver:self];
    [m_pNoteSkinToggler setActionHandler:@selector(noteSkinTogglerChanged) receiver:self];

    // Add controls
    [self pushBackControl:m_pThemeToggler];
    [self pushBackControl:m_pNoteSkinToggler];

    // Temporarily remove ads
//	[[TapMania sharedInstance] toggleAds:NO];
}

- (void)deinitOnTransition
{
    [super deinitOnTransition];

    // Get ads back to place
//	[[TapMania sharedInstance] toggleAds:YES];
}

/* Input handlers */
- (void)themeTogglerChanged
{
    [[SettingsEngine sharedInstance] setStringValue:(NSString *) [[m_pThemeToggler getCurrent] m_pValue] forKey:@"theme"];
}

- (void)noteSkinTogglerChanged
{
    NSString *skinName = (NSString *) [[m_pNoteSkinToggler getCurrent] m_pValue];
    if (![skinName isEqualToString:[ThemeManager sharedInstance].noteskinName])
    {
        [[SettingsEngine sharedInstance] setStringValue:skinName forKey:@"noteskin"];
        [[ThemeManager sharedInstance] selectNoteskin:skinName];
    }
}

@end
