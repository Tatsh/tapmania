//
//  SongPickerMenuRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 07.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "SongPickerMenuRenderer.h"

#import "TMSong.h"

#import "TapManiaAppDelegate.h"
#import "SongsDirectoryCache.h"
#import "TimingUtil.h"

#import "MainMenuRenderer.h"
#import "PhysicsUtil.h"
#import "TMSoundEngine.h"
#import "TMLoopedSound.h"

#import "SongPickerWheel.h"
#import "TogglerItem.h"

#import "InputEngine.h"
#import "TapMania.h"
#import "EAGLView.h"
#import "ThemeManager.h"
#import "SettingsEngine.h"

#import "ZoomEffect.h"
#import "SongPlayRenderer.h"
#import "MainMenuRenderer.h"

#import "QuadTransition.h"
#import "GameState.h"

extern TMGameState * g_pGameState;

@interface SongPickerMenuRenderer (Private)

- (void) backButtonHit;
- (void) difficultyChanged;

- (void) playSong;

@end

@implementation SongPickerMenuRenderer

- (void) dealloc {	
	[m_pSongWheel release];
	[super dealloc];
}

/* TMTransitionSupport methods */
- (void) setupForTransition {
	[super setupForTransition];
	
	// Stop currently playing music
	[[TMSoundEngine sharedInstance] stopMusic]; // Fading:0.5f];
	
	// Cache metrics
	mt_SpeedToggler =		RECT_METRIC(@"SongPickerMenu SpeedToggler");	
	mt_DifficultyToggler =  RECT_METRIC(@"SongPickerMenu DifficultyToggler");
	mt_ModPanel =			RECT_METRIC(@"SongPickerMenu ModPanel");	
	
	mt_ItemSong =			RECT_METRIC(@"SongPickerMenu Wheel ItemSong");
	mt_ItemSongHalfHeight = mt_ItemSong.size.height/2;
	
	mt_HighlightCenter =	RECT_METRIC(@"SongPickerMenu Wheel Highlight");	
	mt_Highlight.size =		mt_HighlightCenter.size;
	
	mt_Highlight.origin.x =  mt_HighlightCenter.origin.x - mt_Highlight.size.width/2;
	mt_Highlight.origin.y =	 mt_HighlightCenter.origin.y - mt_Highlight.size.height/2;
	mt_HighlightHalfHeight = mt_Highlight.size.height/2;
	
	// Cache graphics
	t_SongPickerBG = TEXTURE(@"SongPicker Background");
	t_Highlight = TEXTURE(@"SongPicker Wheel Highlight");
	t_ModPanel = TEXTURE(@"SongPicker Top");
	
	// And sounds
	sr_SelectSong = SOUND(@"SongPicker SelectSong");

	// Create the wheel
	m_pSongWheel = [[SongPickerWheel alloc] init];
	
	m_bStartSongPlay = NO;

	m_pSongWheel = [[SongPickerWheel alloc] init];
	[self pushBackControl:m_pSongWheel];
	
	// Speed mod toggler	
	m_pSpeedToggler = [[ZoomEffect alloc] initWithRenderable:[[TogglerItem alloc] initWithShape:mt_SpeedToggler 
											andCommands:ARRAY_METRIC(@"SongPickerMenu SpeedToggler Elements")]];
	[(TogglerItem*) m_pSpeedToggler selectItemAtIndex:INT_METRIC(@"SongPickerMenu SpeedToggler DefaultElement")];
	[self pushBackControl:m_pSpeedToggler];
	
	// Difficulty toggler
	m_pDifficultyToggler = [[ZoomEffect alloc] initWithRenderable:[[TogglerItem alloc] initWithShape:mt_DifficultyToggler]];
	[(TogglerItem*)m_pDifficultyToggler addItem:[NSNumber numberWithInt:0] withTitle:@"No data"];
	[(TogglerItem*)m_pDifficultyToggler setActionHandler:@selector(difficultyChanged) receiver:self];
	[self pushBackControl:m_pDifficultyToggler];
	
	// Back button
	m_pBackMenuItem = [[ZoomEffect alloc] initWithRenderable:[[MenuItem alloc] initWithMetrics:@"SongPickerMenu BackButton"]];
	[m_pBackMenuItem setActionHandler:@selector(backButtonHit) receiver:self];
	[self pushBackControl:m_pBackMenuItem];
		
	// Get ads back to place if removed
	[[TapMania sharedInstance] toggleAds:YES];
}

- (void) deinitOnTransition {
	[super deinitOnTransition];
			
	// Remove ads
	[[TapMania sharedInstance] toggleAds:NO];
}

/* TMRenderable method */
- (void) render:(float)fDelta {
	CGRect bounds = [TapMania sharedInstance].glView.bounds;
	
	// Draw menu background
	[t_SongPickerBG drawInRect:bounds];
		
	// Draw kids
	[super render:fDelta];
}

/* TMLogicUpdater stuff */
- (void) update:(float)fDelta {	
	[super update:fDelta];
	
	// Check whether we should start playing
	if(m_bStartSongPlay){
		
		// Stop current previewMusic if any
		if(m_pPreviewMusic) {
			[[TMSoundEngine sharedInstance] stopMusic];			
		}
			
		// Play select sound effect
		[[TMSoundEngine sharedInstance] playEffect:sr_SelectSong];
		
		SongPickerMenuItem* selected = (SongPickerMenuItem*)[m_pSongWheel getSelected];
		TMSong* song = [selected song];
		
		// Assign difficulty
		g_pGameState->m_nSelectedDifficulty = (TMSongDifficulty)[(NSNumber*)[(TogglerItem*)m_pDifficultyToggler getCurrent].m_pValue intValue];
		
		SongPlayRenderer* songPlayRenderer = [[SongPlayRenderer alloc] init];
		[songPlayRenderer playSong:song];
		
		[[TapMania sharedInstance] switchToScreen:songPlayRenderer];
		
		m_bStartSongPlay = NO;	// Ensure we are doing this only once
	}
}



- (void) selectSong {
	[(TogglerItem*)m_pDifficultyToggler removeAll];
	
	SongPickerMenuItem* selected = (SongPickerMenuItem*)[[m_pSongWheel getSelected] retain];
	TMSong* song = [selected song];
	
	TMLog(@"Selected song is %@", song.title);
	
	// Get the preffered difficulty level
	int prefDiff = [[SettingsEngine sharedInstance] getIntValue:@"prefdiff"];
	int closestDiffAvailable = 0;
	
	// Go through all possible difficulties
	for(int dif = (int)kSongDifficulty_Invalid; dif < kNumSongDifficulties; ++dif) {
		if([song isDifficultyAvailable:(TMSongDifficulty)dif]){
			NSString* title = [NSString stringWithFormat:@"%@ (%d)", [TMSong difficultyToString:(TMSongDifficulty)dif], [song getDifficultyLevel:(TMSongDifficulty)dif]];
			
			TMLog(@"Add dif %d to toggler as [%@]", dif, title);
			[(TogglerItem*)m_pDifficultyToggler addItem:[NSNumber numberWithInt:dif] withTitle:title];
			
			if(dif-prefDiff < dif-closestDiffAvailable) {
				closestDiffAvailable = dif;
			}
		}
	}
	
	// Set the diff to closest found
	[(TogglerItem*)m_pDifficultyToggler selectItemAtIndex:[(TogglerItem*)m_pDifficultyToggler findIndexByValue:[NSNumber numberWithInt:closestDiffAvailable]]];
	
	// Stop current previewMusic if any
	if(m_pPreviewMusic) {
		[[TMSoundEngine sharedInstance] stopMusic];			
		[m_pPreviewMusic release];
	}
	
	// Play preview music
	NSString *previewMusicPath = [[[SongsDirectoryCache sharedInstance] getSongsPath] stringByAppendingPathComponent:song.m_sMusicFilePath];
	m_pPreviewMusic = [[TMLoopedSound alloc] initWithPath:previewMusicPath atPosition:song.m_fPreviewStart withDuration:song.m_fPreviewDuration];
	
	[[TMSoundEngine sharedInstance] addToQueueWithManualStart:m_pPreviewMusic];
	[[TMSoundEngine sharedInstance] playMusic];
	
	// Mark released to prevent memleaks
	[selected release];
}

- (void) playSong {
	m_bStartSongPlay = YES;
}

/* Support last difficulty setting saving */
- (void) difficultyChanged {
	int curDiff = [(NSNumber*)[(TogglerItem*)m_pDifficultyToggler getCurrent].m_pValue intValue];
	TMLog(@"Changed difficulty. save.");
	
	[[SettingsEngine sharedInstance] setIntValue:curDiff forKey:@"prefdiff"];
}

/* Handle back button */
- (void) backButtonHit {
	// Stop current previewMusic if any
	if(m_pPreviewMusic) {
		[[TMSoundEngine sharedInstance] stopMusic];			
	}
}

@end
