//
//  $Id$
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
#import "ImageButton.h"

#import "InputEngine.h"
#import "TapMania.h"
#import "EAGLView.h"
#import "ThemeManager.h"
#import "SettingsEngine.h"

#import "SongPlayRenderer.h"
#import "MainMenuRenderer.h"

#import "QuadTransition.h"
#import "GameState.h"

#import "GLUtil.h"

extern TMGameState * g_pGameState;

@interface SongPickerMenuRenderer (Private)

- (void) backButtonHit;
- (void) difficultyChanged;

- (void) songSelectionChanged;
- (void) songShouldStart;

@end

@implementation SongPickerMenuRenderer

/* TMTransitionSupport methods */
- (void) setupForTransition {
	[super setupForTransition];
	
	// Stop currently playing music
	[[TMSoundEngine sharedInstance] stopMusic]; // Fading:0.5f];
	
	// Cache metrics
	mt_ItemSong =			RECT_METRIC(@"SongPickerMenu Wheel ItemSong");
	mt_ItemSongHalfHeight = mt_ItemSong.size.height/2;
	
	mt_HighlightCenter =	RECT_METRIC(@"SongPickerMenu Wheel Highlight");	
	mt_Highlight.size =		mt_HighlightCenter.size;
	
	mt_Highlight.origin.x =  mt_HighlightCenter.origin.x - mt_Highlight.size.width/2;
	mt_Highlight.origin.y =	 mt_HighlightCenter.origin.y - mt_Highlight.size.height/2;
	mt_HighlightHalfHeight = mt_Highlight.size.height/2;
	
	// Cache graphics
	t_Highlight = TEXTURE(@"SongPickerMenu Wheel Highlight");
	
	// And sounds
	sr_SelectSong = SOUND(@"SongPickerMenu SelectSong");

	// Push the underlay thing above the wheel
	// TODO: fix this as this is a hack! this should go to a special folder called underlays
	// and automatically be under everything (except the wheel which we programmatically add below it)
	ImageButton* topImg = [[ImageButton alloc] initWithMetrics:@"SongPickerMenu TopImgUnderlay"];
	[self pushChild:topImg];
	
	// Create the wheel
	m_pSongWheel = [[SongPickerWheel alloc] init];
	[m_pSongWheel setActionHandler:@selector(songShouldStart) receiver:self];
	[m_pSongWheel setChangedActionHandler:@selector(songSelectionChanged) receiver:self];
	[self pushControl:m_pSongWheel];
	
	// Difficulty toggler
	m_pDifficultyToggler = [[TogglerItem alloc] initWithMetrics:@"SongPickerMenu DifficultyTogglerCustom"];
	[(TogglerItem*)m_pDifficultyToggler addItem:[NSNumber numberWithInt:0] withTitle:@"No data"];
	[(TogglerItem*)m_pDifficultyToggler setActionHandler:@selector(difficultyChanged) receiver:self];
	[self pushBackControl:m_pDifficultyToggler];
	
	// Back button action
	MenuItem* backButton = (MenuItem*)[self findControl:@"SongPickerMenu BackButton"];
	if(backButton != nil) {
		[backButton setActionHandler:@selector(backButtonHit) receiver:self];
	}
	
	// Select current song (populate difficulty toggler with it's difficulties)
	[self songSelectionChanged];
	
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
	// Draw kids and bg
	[super render:fDelta];
}

/* Wheel actions */
- (void) songSelectionChanged {
	// Drop the texture bind cache as we are going to switch contexts
	TMBindTexture(0);

	[(TogglerItem*)m_pDifficultyToggler removeAll];
	
	SongPickerMenuItem* selected = (SongPickerMenuItem*)[[m_pSongWheel getSelected] retain];
	TMSong* song = [selected song];
	
	TMLog(@"Selected song is %@", song.title);
	
	// Get the preffered difficulty level
	int prefDiff = [[SettingsEngine sharedInstance] getIntValue:@"prefdiff"];
	int closestDiffAvailable = -1024;
	
	// Go through all possible difficulties
	for(int dif = (int)kSongDifficulty_Invalid; dif < kNumSongDifficulties; ++dif) {
		if([song isDifficultyAvailable:(TMSongDifficulty)dif]){
			NSString* title = [NSString stringWithFormat:@"%@ (%d)", [TMSong difficultyToString:(TMSongDifficulty)dif], [song getDifficultyLevel:(TMSongDifficulty)dif]];
			
			TMLog(@"Add dif %d to toggler as [%@]", dif, title);
			[(TogglerItem*)m_pDifficultyToggler addItem:[NSNumber numberWithInt:dif] withTitle:title];
			
			if(dif == prefDiff || abs(prefDiff-dif) < abs(prefDiff-closestDiffAvailable)) {
				closestDiffAvailable = dif;
				TMLog(@"Selected [%d <= %d] %@", dif, prefDiff, [TMSong difficultyToString:(TMSongDifficulty)dif]);
			}
		}
	}
	
	// Set the diff to closest found
	[(TogglerItem*)m_pDifficultyToggler selectItemAtIndex:[(TogglerItem*)m_pDifficultyToggler findIndexByValue:[NSNumber numberWithInt:closestDiffAvailable]]];
	g_pGameState->m_nSelectedDifficulty = (TMSongDifficulty)closestDiffAvailable;
	[m_pSongWheel updateAllWithDifficulty:(TMSongDifficulty)closestDiffAvailable];
	
	// Stop current previewMusic if any
	if(m_pPreviewMusic) {
		[[TMSoundEngine sharedInstance] stopMusic];			
		[m_pPreviewMusic release];
	}
	
	// Play preview music
	NSString *previewMusicPath = [[[SongsDirectoryCache sharedInstance] getSongsPath] stringByAppendingPathComponent:song.m_sMusicFilePath];
	m_pPreviewMusic = [[TMLoopedSound alloc] initWithPath:previewMusicPath atPosition:song.m_fPreviewStart withDuration:song.m_fPreviewDuration];
	
	[[TMSoundEngine sharedInstance] addToQueue:m_pPreviewMusic];
	
	// Mark released to prevent memleaks
	[selected release];	
}

- (void) songShouldStart {
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
	
	// Check speedmod to be sure
	TogglerItem* toggler = (TogglerItem*)[self findControl:@"SongPickerMenu SpeedToggler"];
	if(toggler != nil) {
		[toggler invokeCurrentCommand];
	}
	
	g_pGameState->m_pSong = [song retain];
	[[TapMania sharedInstance] switchToScreen:[SongPlayRenderer class] withMetrics:@"SongPlay"];
}

/* Support last difficulty setting saving */
- (void) difficultyChanged {
	int curDiff = [(NSNumber*)[(TogglerItem*)m_pDifficultyToggler getCurrent].m_pValue intValue];
	TMLog(@"Changed difficulty. save. [%d => %@]", curDiff, [TMSong difficultyToString:(TMSongDifficulty)curDiff]);
	
	[[SettingsEngine sharedInstance] setIntValue:curDiff forKey:@"prefdiff"];
	g_pGameState->m_nSelectedDifficulty = (TMSongDifficulty)curDiff;
	[m_pSongWheel updateAllWithDifficulty:(TMSongDifficulty)curDiff];
}

/* Handle back button */
- (void) backButtonHit {
	// Stop current previewMusic if any
	if(m_pPreviewMusic) {
		[[TMSoundEngine sharedInstance] stopMusic];			
	}
}

@end
