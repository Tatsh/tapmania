//
//  $Id$
//  SongOptionsDialogRenderer.mm
//  TapMania
//
//  Created by Alex Kremer on 12.09.10.
//  Copyright 2010 Godexsoft. All rights reserved.
//


#import "TapMania.h"
#import "InputEngine.h"
#import "EAGLView.h"
#import "ThemeManager.h"
#import "Texture2D.h"
#import "SettingsEngine.h"

#import "TogglerItem.h"
#import "SongOptionsDialogRenderer.h"

#import "TMSoundEngine.h"
#import "Flurry.h"

@interface SongOptionsDialogRenderer (InputHandling)
- (void)noteSkinTogglerChanged;

- (void)speedChanged;

- (void)receptorModsChanged;

- (void)noteModsChanged;
@end

@implementation SongOptionsDialogRenderer

- (id)initWithMetrics:(NSString *)inMetricsKey
{
    self = [super initWithMetrics:inMetricsKey];
    if (!self)
        return nil;

    [Flurry logEvent:@"song_options_enter"];

    // NoteSkin selection
    m_pNoteSkinToggler = [[TogglerItem alloc] initWithMetrics:@"SongOptions NoteSkinTogglerCustom"];

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

    // Populate SpeedMods and select preferred speed value
    m_pSpeedToggler = (TogglerItem *) [self findControl:@"SongOptions SpeedToggler"];
    [m_pSpeedToggler setElementsWithMetric:@"SpeedMods"];

    [m_pSpeedToggler selectItemAtIndex:[[SettingsEngine sharedInstance] getIntValue:@"prefspeed"]];

    // Mods
    m_pReceptorModsToggler = (TogglerItem *) [self findControl:@"SongOptions ReceptorModToggler"];
    m_pNoteModsToggler = (TogglerItem *) [self findControl:@"SongOptions NoteModToggler"];
    [m_pReceptorModsToggler selectItemAtIndex:[[SettingsEngine sharedInstance] getIntValue:@"receptor_mods"]];
    [m_pNoteModsToggler selectItemAtIndex:[[SettingsEngine sharedInstance] getIntValue:@"note_mods"]];

    // Setup action handlers
    [m_pNoteSkinToggler setActionHandler:@selector(noteSkinTogglerChanged) receiver:self];
    [m_pSpeedToggler setActionHandler:@selector(speedChanged) receiver:self];
    [m_pReceptorModsToggler setActionHandler:@selector(receptorModsChanged) receiver:self];
    [m_pNoteModsToggler setActionHandler:@selector(noteModsChanged) receiver:self];


    // Add controls
    [self pushBackControl:m_pNoteSkinToggler];

    // Temporarily remove ads
    [[TapMania sharedInstance] toggleAds:NO];

    return self;
}

- (void)dealloc
{

    // Get ads back to place
    [[TapMania sharedInstance] toggleAds:YES];

    [super dealloc];
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

/* Support speed change saving */
- (void)speedChanged
{
    int curSpeed = [(TogglerItem *) m_pSpeedToggler getCurrentIndex];
    [[SettingsEngine sharedInstance] setIntValue:curSpeed forKey:@"prefspeed"];
}

/* Support mods change saving */
- (void)receptorModsChanged
{
    int cur = [(TogglerItem *) m_pReceptorModsToggler getCurrentIndex];
    [[SettingsEngine sharedInstance] setIntValue:cur forKey:@"receptor_mods"];
}

- (void)noteModsChanged
{
    int cur = [(TogglerItem *) m_pNoteModsToggler getCurrentIndex];
    [[SettingsEngine sharedInstance] setIntValue:cur forKey:@"note_mods"];
}


@end
