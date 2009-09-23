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

#import "SongPickerMenuItem.h"
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

- (void) saveSwipeElement:(float)value withTime:(float)delta;
- (float) calculateSwipeVelocity;
- (void) clearSwipes;

- (void) rollWheel:(float) pixels;
- (void) backButtonHit;
- (void) difficultyChanged;

- (float) findClosest;
- (void) selectSong;
- (void) playSong;

@end

@implementation SongPickerMenuRenderer

- (void) dealloc {
	
	// Explicitly deallocate memory
	int i;
	for(i=0; i<[m_pWheelItems count]; ++i) {
		[[m_pWheelItems objectAtIndex:i] release];
	}	
	
	[m_pWheelItems release];
	
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
	
	m_pWheelItems = [[NSMutableArray alloc] initWithCapacity:kNumWheelItems];
	NSArray* songList = [[SongsDirectoryCache sharedInstance] getSongList];
	
	m_fVelocity = 0.0f;
	m_bStartSongPlay = NO;
	
	[self clearSwipes];
	
	float curYOffset = 0.0f;
	int i,j = 0;
	
	for(i=0; i<kNumWheelItems; i++) {		
		if(j == [songList count]) {
			j = 0;
		}
		
		TMSong *song = [songList objectAtIndex:j++];				
		[m_pWheelItems addObject:[[SongPickerMenuItem alloc] initWithSong:song atPoint:CGPointMake(mt_ItemSong.origin.x, curYOffset)]];
		
		curYOffset += mt_ItemSong.size.height;
	}
	
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
		
	// Populate difficulty toggler with current song
	[self selectSong];	
	
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
	
	int i;
	for(i=0; i<[m_pWheelItems count]; i++){
		[(SongPickerMenuItem*)[m_pWheelItems objectAtIndex:i] render:fDelta];
	}
	
	// Highlight selection and draw top element
	glEnable(GL_BLEND);
	[t_ModPanel drawInRect:mt_ModPanel];
	[t_Highlight drawAtPoint:mt_HighlightCenter.origin];
	glDisable(GL_BLEND);

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
		
		SongPickerMenuItem* selected = (SongPickerMenuItem*)[m_pWheelItems objectAtIndex:kSelectedWheelItemId];
		TMSong* song = [selected song];
		
		// Assign difficulty
		g_pGameState->m_nSelectedDifficulty = (TMSongDifficulty)[(NSNumber*)[(TogglerItem*)m_pDifficultyToggler getCurrent].m_pValue intValue];
		
		SongPlayRenderer* songPlayRenderer = [[SongPlayRenderer alloc] init];
		[songPlayRenderer playSong:song];
		
		[[TapMania sharedInstance] switchToScreen:songPlayRenderer];
		
		m_bStartSongPlay = NO;	// Ensure we are doing this only once
	}
	
	// Do all scroll related stuff
	if(m_fVelocity != 0.0f) {
		
		float frictionForce = kWheelStaticFriction * (-kWheelMass*kGravity);
		float frictionDelta = fDelta * frictionForce;
		
		if(fabsf(m_fVelocity) < frictionDelta) {
			m_fVelocity = 0.0f;
			
			float closestY = [self findClosest];
			if(closestY != 0.0f) {
				[self rollWheel: -closestY];
				[self selectSong];
			}
			
			return;
		} else {

			if(m_fVelocity < 0.0f) {
				m_fVelocity += frictionDelta;
			} else {
				m_fVelocity -= frictionDelta;
			}

			[self rollWheel: fDelta * m_fVelocity];
		}
	}
}

/* TMGameUIResponder methods */
- (BOOL) tmTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	// Handle wheel
	switch ([touches count]) {
		case 1:
		{
			UITouch* touch = [touches anyObject];
			CGPoint pos = [touch locationInView:[TapMania sharedInstance].glView];
			CGPoint pointGl = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:pos];
		
			if(pointGl.y < mt_ModPanel.origin.y) {
				m_fLastSwipeY = pointGl.y;
				m_fVelocity = 0.0f;	// Stop scrollin if touching the screen
				m_dLastSwipeTime = [touch timestamp];
			}
				
			break;
		}
	}
	
	return YES;
}

- (BOOL) tmTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	// Handle wheel
	switch ([touches count]) {
		case 1:
		{
			UITouch* touch = [touches anyObject];
			CGPoint pos = [touch locationInView:[TapMania sharedInstance].glView];
			CGPoint pointGl = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:pos];

			if(pointGl.y < mt_ModPanel.origin.y) {
				float yDelta = pointGl.y-m_fLastSwipeY;
				
				[self saveSwipeElement:yDelta withTime:[touch timestamp]-m_dLastSwipeTime];
				m_fLastSwipeY = pointGl.y;
				m_dLastSwipeTime = [touch timestamp];
				
				[self rollWheel:yDelta];	// Roll the wheel				
			} else {
				[self clearSwipes];
			}
			
			break;
		}
	}
	
	return YES;
}

- (BOOL) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	if([touches count] == 1){		
		UITouch* touch = [touches anyObject];
		CGPoint pos = [touch locationInView:[TapMania sharedInstance].glView];
		CGPoint pointGl = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:pos];
		
		// Should start song?
		if([touch tapCount] > 1 && CGRectContainsPoint(mt_Highlight, pointGl)) {
			[self playSong];
			return YES;
		}
		
		// Now the fun part - swipes
		if(pointGl.y < mt_ModPanel.origin.y) {
			m_fVelocity = [self calculateSwipeVelocity];
			if(m_fVelocity == 0.0f) m_fVelocity = 0.01f;	// Make it jump to closest anyway
		}
		
		[self clearSwipes];
	}
	
	return YES;
}

- (void) clearSwipes {	
	int i;
	for(i=0; i<kNumSwipePositions; ++i) {
		m_fSwipeBuffer[i][0] = 0.0f;
		m_fSwipeBuffer[i][1] = 0.0f;
	}
	
	m_nCurrentSwipePosition = 0;
	m_fLastSwipeY = 0.0f;
}	

- (float) calculateSwipeVelocity {
	int i;
	float totalVelocity = 0.0f;	
	float totalTime = 0.0f;
	
	for(i=0; i<kNumSwipePositions; ++i) {
		totalTime += m_fSwipeBuffer[i][0];
		totalVelocity += m_fSwipeBuffer[i][1];
	}
	
	// Get average
	totalTime /= kNumSwipePositions;
	totalVelocity /= kNumSwipePositions;
	
	// v = d/t
	if(totalTime > 0.0f) {
		totalVelocity /= totalTime;
	}
	
	TMLog(@"Got swipe velocity: %f from delta time %f", totalVelocity, totalTime);
	
	return totalVelocity;
}

- (void) saveSwipeElement:(float)value withTime:(float)delta {
	if(m_nCurrentSwipePosition == kNumSwipePositions-1) {
		m_nCurrentSwipePosition = 0;
	}
	
	m_fSwipeBuffer[m_nCurrentSwipePosition][0] = delta;
	m_fSwipeBuffer[m_nCurrentSwipePosition][1] = value;
	
	++m_nCurrentSwipePosition;
}

- (void) rollWheel:(float) pixels {
	int i;
	for(i=0; i<[m_pWheelItems count]; ++i) {
		SongPickerMenuItem* item = (SongPickerMenuItem*)[m_pWheelItems objectAtIndex:i];		
		[item updateYPosition:pixels];
	}
	
	// Check last object
	SongPickerMenuItem* item = (SongPickerMenuItem*)[m_pWheelItems objectAtIndex:0];
	float lastWheelItemY = [item getPosition].y;
	
	do {
		
		if (lastWheelItemY <= -mt_ItemSongHalfHeight ) {		
			// Explicitly deallocate the object. autorelease didn't work for some reason.
			SongPickerMenuItem* itemToRemove = (SongPickerMenuItem*)[m_pWheelItems objectAtIndex:0];
			[m_pWheelItems removeObjectAtIndex:0];
			
			// Now we must add one on top of the wheel (last element of the array)
			float firstWheelItemY = lastWheelItemY + mt_ItemSong.size.height*kNumWheelItems;

			// Get current song on top of the wheel
			SongPickerMenuItem* lastItem = (SongPickerMenuItem*)[m_pWheelItems lastObject];
			TMSong* searchSong = [lastItem song];				
			TMSong *song = [[SongsDirectoryCache sharedInstance] getSongPrevFrom:searchSong];				
			
			[itemToRemove updateWithSong:song atPoint:CGPointMake(mt_ItemSong.origin.x, firstWheelItemY)];
			[m_pWheelItems addObject:itemToRemove];							
			
		} else if(lastWheelItemY >= mt_ItemSongHalfHeight) {		
			// Explicitly deallocate the object. autorelease didn't work for some reason.
			SongPickerMenuItem* itemToRemove = (SongPickerMenuItem*)[m_pWheelItems lastObject];
			[m_pWheelItems removeLastObject];
			
			// Now we must add one on the bottom of the wheel (first element of the array)
			float newLastWheelItemY = lastWheelItemY - mt_ItemSong.size.height;
			
			// Get current song on bottom of the wheel
			SongPickerMenuItem* firstItem = (SongPickerMenuItem*)[m_pWheelItems objectAtIndex:0];
			TMSong* searchSong = [firstItem song];				
			TMSong *song = [[SongsDirectoryCache sharedInstance] getSongNextTo:searchSong];				
			
			[itemToRemove updateWithSong:song atPoint:CGPointMake(mt_ItemSong.origin.x, newLastWheelItemY)];
			[m_pWheelItems insertObject:itemToRemove atIndex:0];						
		}

		// get possibly new first item
		SongPickerMenuItem* firstItem = (SongPickerMenuItem*)[m_pWheelItems objectAtIndex:0];
		lastWheelItemY = [firstItem getPosition].y;
		
	} while (lastWheelItemY < -mt_ItemSongHalfHeight || lastWheelItemY > mt_ItemSongHalfHeight);
}

- (float) findClosest {
	float tmp = MAXFLOAT;	// Holds current minimum
	int i;
	
	for(i=kSelectedWheelItemId-2; i<kSelectedWheelItemId+2; ++i) {
		float t = [(SongPickerMenuItem*)[m_pWheelItems objectAtIndex:i] getPosition].y - mt_HighlightCenter.origin.y;
		if(fabsf(t) < fabsf(tmp)) { tmp = t; }
	}
	
	return tmp;
}

- (void) selectSong {
	[(TogglerItem*)m_pDifficultyToggler removeAll];
	
	SongPickerMenuItem* selected = (SongPickerMenuItem*)[[m_pWheelItems objectAtIndex:kSelectedWheelItemId] retain];
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
