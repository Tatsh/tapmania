//
//  SongPickerMenuRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 07.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "SongPickerMenuRenderer.h"

#import "TMSong.h"
#import "TMSongOptions.h"

#import "TapManiaAppDelegate.h"
#import "SongsDirectoryCache.h"
#import "TimingUtil.h"

#import "MainMenuRenderer.h"
#import "PhysicsUtil.h"

#import "SongPickerMenuItem.h"
#import "TogglerItem.h"

#import "InputEngine.h"
#import "TapMania.h"
#import "EAGLView.h"
#import "ThemeManager.h"

#import "ZoomEffect.h"
#import "SongPlayRenderer.h"
#import "MainMenuRenderer.h"

#import "QuadTransition.h"

@interface SongPickerMenuRenderer (Private)

- (void) saveSwipeElement:(float)value withTime:(float)delta;
- (float) calculateSwipeVelocity;
- (void) clearSwipes;

- (void) rollWheel:(float) pixels;
- (void) backButtonHit;

- (float) findClosest;
- (void) selectSong;
- (void) playSong;

@end

@implementation SongPickerMenuRenderer

int mt_SpeedTogglerX, mt_SpeedTogglerY, mt_SpeedTogglerWidth, mt_SpeedTogglerHeight;
int mt_DifficultyTogglerX, mt_DifficultyTogglerY, mt_DifficultyTogglerWidth, mt_DifficultyTogglerHeight;
int mt_BackButtonX, mt_BackButtonY, mt_BackButtonWidth, mt_BackButtonHeight;
int mt_ModPanelX, mt_ModPanelY, mt_ModPanelWidth, mt_ModPanelHeight;
int mt_ItemSongHeight, mt_ItemSongCenterX, mt_ItemSongHalfHeight;
int mt_HighlightCenterX, mt_HighlightCenterY;
int mt_HighlightX, mt_HighlightY, mt_HighlightWidth, mt_HighlightHeight, mt_HighlightHalfHeight;

Texture2D* t_SongPickerBG;
Texture2D* t_Highlight;
Texture2D* t_ModPanel;

- (void) dealloc {
	
	// Explicitly deallocate memory
	int i;
	for(i=0; i<[m_pWheelItems count]; ++i) {
		[[m_pWheelItems objectAtIndex:i] release];
	}	
	
	[m_pWheelItems release];
	[m_pSpeedToggler release];
	[m_pDifficultyToggler release];
	[m_pBackMenuItem release];
	
	[super dealloc];
}

/* TMTransitionSupport methods */
- (void) setupForTransition {
	// Cache metrics
	mt_SpeedTogglerX = [[ThemeManager sharedInstance] intMetric:@"SongPickerMenu SpeedToggler X"];
	mt_SpeedTogglerY = [[ThemeManager sharedInstance] intMetric:@"SongPickerMenu SpeedToggler Y"];
	mt_SpeedTogglerWidth = [[ThemeManager sharedInstance] intMetric:@"SongPickerMenu SpeedToggler Width"];
	mt_SpeedTogglerHeight = [[ThemeManager sharedInstance] intMetric:@"SongPickerMenu SpeedToggler Height"];
	
	mt_DifficultyTogglerX = [[ThemeManager sharedInstance] intMetric:@"SongPickerMenu DifficultyToggler X"];
	mt_DifficultyTogglerY = [[ThemeManager sharedInstance] intMetric:@"SongPickerMenu DifficultyToggler Y"];
	mt_DifficultyTogglerWidth = [[ThemeManager sharedInstance] intMetric:@"SongPickerMenu DifficultyToggler Width"];
	mt_DifficultyTogglerHeight = [[ThemeManager sharedInstance] intMetric:@"SongPickerMenu DifficultyToggler Height"];
	
	mt_BackButtonX = [[ThemeManager sharedInstance] intMetric:@"SongPickerMenu BackButton X"];
	mt_BackButtonY = [[ThemeManager sharedInstance] intMetric:@"SongPickerMenu BackButton Y"];
	mt_BackButtonWidth = [[ThemeManager sharedInstance] intMetric:@"SongPickerMenu BackButton Width"];
	mt_BackButtonHeight = [[ThemeManager sharedInstance] intMetric:@"SongPickerMenu BackButton Height"];
	
	mt_ModPanelX = [[ThemeManager sharedInstance] intMetric:@"SongPickerMenu ModPanel X"];
	mt_ModPanelY = [[ThemeManager sharedInstance] intMetric:@"SongPickerMenu ModPanel Y"];
	mt_ModPanelWidth = [[ThemeManager sharedInstance] intMetric:@"SongPickerMenu ModPanel Width"];
	mt_ModPanelHeight = [[ThemeManager sharedInstance] intMetric:@"SongPickerMenu ModPanel Height"];
	
	mt_ItemSongHeight = [[ThemeManager sharedInstance] intMetric:@"SongPickerMenu Wheel ItemSong Height"];
	mt_ItemSongCenterX = [[ThemeManager sharedInstance] intMetric:@"SongPickerMenu Wheel ItemSong CenterX"];
	mt_ItemSongHalfHeight = mt_ItemSongHeight/2;
	
	mt_HighlightCenterX = [[ThemeManager sharedInstance] intMetric:@"SongPickerMenu Wheel Highlight CenterX"];
	mt_HighlightCenterY = [[ThemeManager sharedInstance] intMetric:@"SongPickerMenu Wheel Highlight CenterY"];
	mt_HighlightWidth = [[ThemeManager sharedInstance] intMetric:@"SongPickerMenu Wheel Highlight Width"];
	mt_HighlightHeight = [[ThemeManager sharedInstance] intMetric:@"SongPickerMenu Wheel Highlight Height"];
	
	mt_HighlightX = mt_HighlightCenterX - mt_HighlightWidth/2;
	mt_HighlightY = mt_HighlightCenterY - mt_HighlightHeight/2;
	mt_HighlightHalfHeight = mt_HighlightHeight/2;
	
	// Cache graphics
	t_SongPickerBG = [[ThemeManager sharedInstance] texture:@"SongPicker Background"];
	t_Highlight = [[ThemeManager sharedInstance] texture:@"SongPicker Wheel Highlight"];
	t_ModPanel = [[ThemeManager sharedInstance] texture:@"SongPicker Top"];
	
	m_pWheelItems = [[NSMutableArray alloc] initWithCapacity:kNumWheelItems];
	NSArray* songList = [[SongsDirectoryCache sharedInstance] getSongList];
	
	m_fVelocity = 0.0f;
	m_bStartSongPlay = NO;
	
	[self clearSwipes];
	
	float curYOffset = 0.0f;
	int i;
	int j = 0;
	
	for(i=0; i<kNumWheelItems; i++) {
		
		if(j == [songList count]) {
			j = 0;
		}
		
		TMSong *song = [songList objectAtIndex:j++];				
		[m_pWheelItems addObject:[[SongPickerMenuItem alloc] initWithSong:song atPoint:CGPointMake(mt_ItemSongCenterX, curYOffset)]];
		
		curYOffset += mt_ItemSongHeight;
	}
	
	// Speed mod toggler	
	m_pSpeedToggler = [[ZoomEffect alloc] initWithRenderable:[[TogglerItem alloc] initWithShape:CGRectMake(mt_SpeedTogglerX, mt_SpeedTogglerY, mt_SpeedTogglerWidth, mt_SpeedTogglerHeight)]];
	[(TogglerItem*)m_pSpeedToggler addItem:[NSNumber numberWithInt:kSpeedMod_1x] withTitle:[TMSongOptions speedModAsString:kSpeedMod_1x]];
	[(TogglerItem*)m_pSpeedToggler addItem:[NSNumber numberWithInt:kSpeedMod_1_5x] withTitle:[TMSongOptions speedModAsString:kSpeedMod_1_5x]];
	[(TogglerItem*)m_pSpeedToggler addItem:[NSNumber numberWithInt:kSpeedMod_2x] withTitle:[TMSongOptions speedModAsString:kSpeedMod_2x]];
	[(TogglerItem*)m_pSpeedToggler addItem:[NSNumber numberWithInt:kSpeedMod_3x] withTitle:[TMSongOptions speedModAsString:kSpeedMod_3x]];
	[(TogglerItem*)m_pSpeedToggler addItem:[NSNumber numberWithInt:kSpeedMod_5x] withTitle:[TMSongOptions speedModAsString:kSpeedMod_5x]];
	[(TogglerItem*)m_pSpeedToggler addItem:[NSNumber numberWithInt:kSpeedMod_8x] withTitle:[TMSongOptions speedModAsString:kSpeedMod_8x]];
	
	// Difficulty toggler
	m_pDifficultyToggler = [[ZoomEffect alloc] initWithRenderable:[[TogglerItem alloc] initWithShape:CGRectMake(mt_DifficultyTogglerX, mt_DifficultyTogglerY, mt_DifficultyTogglerWidth, mt_DifficultyTogglerHeight)]];
	[(TogglerItem*)m_pDifficultyToggler addItem:[NSNumber numberWithInt:0] withTitle:@"No data"];
	
	// Back button
	m_pBackMenuItem = [[ZoomEffect alloc] initWithRenderable:[[MenuItem alloc] initWithTitle:@"Back" andShape:CGRectMake(mt_BackButtonX, mt_BackButtonY, mt_BackButtonWidth, mt_BackButtonHeight)]];
	[m_pBackMenuItem setActionHandler:@selector(backButtonHit) receiver:self];
	
	// Populate difficulty toggler with current song
	[self selectSong];	
	
	// Subscribe for input events
	[[InputEngine sharedInstance] subscribe:self];
	[[InputEngine sharedInstance] subscribe:m_pSpeedToggler];
	[[InputEngine sharedInstance] subscribe:m_pDifficultyToggler];
	[[InputEngine sharedInstance] subscribe:m_pBackMenuItem];
	
	// Add the items with low priority
	[[TapMania sharedInstance] registerObject:m_pSpeedToggler withPriority:kRunLoopPriority_NormalUpper];
	[[TapMania sharedInstance] registerObject:m_pDifficultyToggler withPriority:kRunLoopPriority_NormalUpper-1];
	[[TapMania sharedInstance] registerObject:m_pBackMenuItem withPriority:kRunLoopPriority_NormalUpper-2];
}

- (void) deinitOnTransition {
	// Unsubscribe from input events
	[[InputEngine sharedInstance] unsubscribe:self];
	[[InputEngine sharedInstance] unsubscribe:m_pSpeedToggler];
	[[InputEngine sharedInstance] unsubscribe:m_pDifficultyToggler];
	[[InputEngine sharedInstance] unsubscribe:m_pBackMenuItem];
	
	// Remove the items
	[[TapMania sharedInstance] deregisterObject:m_pSpeedToggler];
	[[TapMania sharedInstance] deregisterObject:m_pDifficultyToggler];
	[[TapMania sharedInstance] deregisterObject:m_pBackMenuItem];
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
	[t_ModPanel drawInRect:CGRectMake(mt_ModPanelX, mt_ModPanelY, mt_ModPanelWidth, mt_ModPanelHeight)];
	[t_Highlight drawAtPoint:CGPointMake(mt_HighlightCenterX, mt_HighlightCenterY)];
	glDisable(GL_BLEND);

}

/* TMLogicUpdater stuff */
- (void) update:(float)fDelta {
	
	// Check whether we should start playing
	if(m_bStartSongPlay){
		
		SongPickerMenuItem* selected = (SongPickerMenuItem*)[m_pWheelItems objectAtIndex:kSelectedWheelItemId];
		TMSong* song = [selected song];
		TMSongOptions* options = [[TMSongOptions alloc] init];
		
		// Assign speed modifier
		[options setSpeedMod:[(NSNumber*)[(TogglerItem*)m_pSpeedToggler getCurrent].m_pValue intValue]]; 
		
		// Assign difficulty
		[options setDifficulty:[(NSNumber*)[(TogglerItem*)m_pDifficultyToggler getCurrent].m_pValue intValue]];
		
		SongPlayRenderer* songPlayRenderer = [[SongPlayRenderer alloc] init];
		[songPlayRenderer playSong:song withOptions:options];
		
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
- (void) tmTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	// Handle wheel
	switch ([touches count]) {
		case 1:
		{
			UITouch* touch = [touches anyObject];
			CGPoint pos = [touch locationInView:[TapMania sharedInstance].glView];
			CGPoint pointGl = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:pos];
		
			if(pointGl.y < mt_ModPanelY) {
				m_fLastSwipeY = pointGl.y;
				m_fVelocity = 0.0f;	// Stop scrollin if touching the screen
				m_dLastSwipeTime = [touch timestamp];
			}
				
			break;
		}
	}
}

- (void) tmTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	// Handle wheel
	switch ([touches count]) {
		case 1:
		{
			UITouch* touch = [touches anyObject];
			CGPoint pos = [touch locationInView:[TapMania sharedInstance].glView];
			CGPoint pointGl = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:pos];

			if(pointGl.y < mt_ModPanelY) {
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
}

- (void) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	if([touches count] == 1){		
		UITouch* touch = [touches anyObject];
		CGPoint pos = [touch locationInView:[TapMania sharedInstance].glView];
		CGPoint pointGl = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:pos];

		CGRect startSongRect = CGRectMake(mt_HighlightX, mt_HighlightY, mt_HighlightWidth, mt_HighlightHeight);
		
		// Should start song?
		if([touch tapCount] > 1 && CGRectContainsPoint(startSongRect, pointGl)) {
			[self playSong];
			return;
		}
		
		// Now the fun part - swipes
		if(pointGl.y < mt_ModPanelY) {
			m_fVelocity = [self calculateSwipeVelocity];
			if(m_fVelocity == 0.0f) m_fVelocity = 0.01f;	// Make it jump to closest anyway
		}
		
		[self clearSwipes];
	}
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
			float firstWheelItemY = lastWheelItemY + mt_ItemSongHeight*kNumWheelItems;

			// Get current song on top of the wheel
			SongPickerMenuItem* lastItem = (SongPickerMenuItem*)[m_pWheelItems lastObject];
			TMSong* searchSong = [lastItem song];				
			TMSong *song = [[SongsDirectoryCache sharedInstance] getSongPrevFrom:searchSong];				
			
			[itemToRemove updateWithSong:song atPoint:CGPointMake(mt_ItemSongCenterX, firstWheelItemY)];
			[m_pWheelItems addObject:itemToRemove];							
			
		} else if(lastWheelItemY >= mt_ItemSongHalfHeight) {		
			// Explicitly deallocate the object. autorelease didn't work for some reason.
			SongPickerMenuItem* itemToRemove = (SongPickerMenuItem*)[m_pWheelItems lastObject];
			[m_pWheelItems removeLastObject];
			
			// Now we must add one on the bottom of the wheel (first element of the array)
			float newLastWheelItemY = lastWheelItemY - mt_ItemSongHeight;
			
			// Get current song on bottom of the wheel
			SongPickerMenuItem* firstItem = (SongPickerMenuItem*)[m_pWheelItems objectAtIndex:0];
			TMSong* searchSong = [firstItem song];				
			TMSong *song = [[SongsDirectoryCache sharedInstance] getSongNextTo:searchSong];				
			
			[itemToRemove updateWithSong:song atPoint:CGPointMake(mt_ItemSongCenterX, newLastWheelItemY)];
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
		float t = [(SongPickerMenuItem*)[m_pWheelItems objectAtIndex:i] getPosition].y - mt_HighlightCenterY;
		if(fabsf(t) < fabsf(tmp)) { tmp = t; }
	}
	
	return tmp;
}

- (void) selectSong {
	[(TogglerItem*)m_pDifficultyToggler removeAll];
	
	SongPickerMenuItem* selected = (SongPickerMenuItem*)[[m_pWheelItems objectAtIndex:kSelectedWheelItemId] retain];
	TMSong* song = [selected song];
	
	TMLog(@"Selected song is %@", song.title);
	
	// Go through all possible difficulties
	TMSongDifficulty dif = kSongDifficulty_Invalid;
	for(; dif < kNumSongDifficulties; ++dif) {
		if([song isDifficultyAvailable:dif]){
			NSString* title = [NSString stringWithFormat:@"%@ (%d)", [TMSong difficultyToString:dif], [song getDifficultyLevel:dif]];
			
			TMLog(@"Add dif %d to toggler as [%@]", dif, title);
			[(TogglerItem*)m_pDifficultyToggler addItem:[NSNumber numberWithInt:dif] withTitle:title];
		}
	}
	
	// Mark released to prevent memleaks
	[selected release];
}

- (void) playSong {
	m_bStartSongPlay = YES;
}

/* Handle back button */
- (void) backButtonHit {
	[[TapMania sharedInstance] switchToScreen:[[MainMenuRenderer alloc] init] usingTransition:[QuadTransition class]];
}

@end
