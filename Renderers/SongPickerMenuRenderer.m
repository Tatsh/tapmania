//
//  SongPickerMenuRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 07.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <syslog.h>

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

@end

@implementation SongPickerMenuRenderer

int mt_SpeedTogglerX, mt_SpeedTogglerY, mt_SpeedTogglerWidth, mt_SpeedTogglerHeight;

Texture2D* t_SongPickerBG;
Texture2D* t_Highlight;
Texture2D* t_Top;
Texture2D* t_MenuBack;

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	// Cache metrics
	mt_SpeedTogglerX = [[ThemeManager sharedInstance] intMetric:@"SongSelection SpeedToggler X"];
	mt_SpeedTogglerY = [[ThemeManager sharedInstance] intMetric:@"SongSelection SpeedToggler Y"];
	mt_SpeedTogglerWidth = [[ThemeManager sharedInstance] intMetric:@"SongSelection SpeedToggler Width"];
	mt_SpeedTogglerHeight = [[ThemeManager sharedInstance] intMetric:@"SongSelection SpeedToggler Height"];
	
	// Cache graphics
	t_SongPickerBG = [[ThemeManager sharedInstance] texture:@"SongPicker Background"];
	t_Highlight = [[ThemeManager sharedInstance] texture:@"SongPicker Wheel Highlight"];
	t_Top = [[ThemeManager sharedInstance] texture:@"SongPicker Top"];
	t_MenuBack = [[ThemeManager sharedInstance] texture:@"SongPicker BackButton"];
	
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
		[m_pWheelItems addObject:[[SongPickerMenuItem alloc] initWithSong:song atPoint:CGPointMake(165.0f, curYOffset)]];
		
		curYOffset += 46.0f;
	}
	
	// Speed mod toggler	
	m_pSpeedToggler = [[ZoomEffect alloc] initWithRenderable:[[TogglerItem alloc] initWithShape:CGRectMake(255.0f, 433.0f, 60.0f, 40.0f)]];
	[(TogglerItem*)m_pSpeedToggler addItem:[NSNumber numberWithInt:kSpeedMod_1x] withTitle:[TMSongOptions speedModAsString:kSpeedMod_1x]];
	[(TogglerItem*)m_pSpeedToggler addItem:[NSNumber numberWithInt:kSpeedMod_1_5x] withTitle:[TMSongOptions speedModAsString:kSpeedMod_1_5x]];
	[(TogglerItem*)m_pSpeedToggler addItem:[NSNumber numberWithInt:kSpeedMod_2x] withTitle:[TMSongOptions speedModAsString:kSpeedMod_2x]];
	[(TogglerItem*)m_pSpeedToggler addItem:[NSNumber numberWithInt:kSpeedMod_3x] withTitle:[TMSongOptions speedModAsString:kSpeedMod_3x]];
	[(TogglerItem*)m_pSpeedToggler addItem:[NSNumber numberWithInt:kSpeedMod_5x] withTitle:[TMSongOptions speedModAsString:kSpeedMod_5x]];
	[(TogglerItem*)m_pSpeedToggler addItem:[NSNumber numberWithInt:kSpeedMod_8x] withTitle:[TMSongOptions speedModAsString:kSpeedMod_8x]];
		
	// Difficulty toggler
	m_pDifficultyToggler = [[ZoomEffect alloc] initWithRenderable:[[TogglerItem alloc] initWithShape:CGRectMake(70.0f, 433.0f, 180.0f, 40.0f)]];
	[(TogglerItem*)m_pDifficultyToggler addItem:[NSNumber numberWithInt:0] withTitle:@"No data"];
	
	// Back button
	m_pBackMenuItem = [[ZoomEffect alloc] initWithRenderable:[[MenuItem alloc] initWithTexture:t_MenuBack andShape:CGRectMake(5.0f, 433.0f, 60.0f, 40.0f)]];
	[m_pBackMenuItem setActionHandler:@selector(backButtonHit) receiver:self];
	
	// Populate difficulty toggler with current song
	[self selectSong];
	
	return self;
}

- (void) dealloc {
	[m_pWheelItems removeAllObjects];
	[m_pWheelItems release];
	[m_pSpeedToggler release];
	[m_pDifficultyToggler release];
	[m_pBackMenuItem release];
	
	[super dealloc];
}

/* TMTransitionSupport methods */
- (void) setupForTransition {
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
- (void) render:(NSNumber*)fDelta {
	CGRect bounds = [TapMania sharedInstance].glView.bounds;
	
	// Draw menu background
	[t_SongPickerBG drawInRect:bounds];
	
	// Positions of the wheel items are fixed
	int i;
	for(i=0; i<[m_pWheelItems count]; i++){
		[(SongPickerMenuItem*)[m_pWheelItems objectAtIndex:i] render:fDelta];
	}
	
	// Highlight selection and draw top element
	glEnable(GL_BLEND);
	[t_Top drawInRect:CGRectMake(0.0f, 410.0f, 320.0f, 70.0f)];
	[t_Highlight drawAtPoint:CGPointMake(165.0f, 184.0f)];
	glDisable(GL_BLEND);

}

/* TMLogicUpdater stuff */
- (void) update:(NSNumber*)fDelta {
	
	// Check whether we should start playing
	if(m_bStartSongPlay){
		
		TMSongOptions* options = [[TMSongOptions alloc] init];
		
		// Assign speed modifier
		[options setSpeedMod:[(NSNumber*)[(TogglerItem*)m_pSpeedToggler getCurrent].m_pValue intValue]]; 
		
		// Assign difficulty
		[options setDifficulty:kSongDifficulty_Hard];
		
		SongPlayRenderer* songPlayRenderer = [[SongPlayRenderer alloc] init];
		[songPlayRenderer playSong:((SongPickerMenuItem*)[m_pWheelItems objectAtIndex:kSelectedWheelItemId]).m_pSong withOptions:options];
		
		[[TapMania sharedInstance] switchToScreen:songPlayRenderer];
		
		m_bStartSongPlay = NO;	// Ensure we are doing this only once
	}
	
	// Do all scroll related stuff
	if(m_fVelocity != 0.0f) {
		
		float frictionForce = kWheelStaticFriction * (-kWheelMass*kGravity);
		float frictionDelta = [fDelta floatValue] * frictionForce;
		
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

			[self rollWheel: [fDelta floatValue] * m_fVelocity];
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
			
			m_fLastSwipeY = pointGl.y;
			m_fVelocity = 0.0f;	// Stop scrollin if touching the screen
			m_dLastSwipeTime = [touch timestamp];
			
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
			
			float yDelta = pointGl.y-m_fLastSwipeY;
			
			[self saveSwipeElement:yDelta withTime:[touch timestamp]-m_dLastSwipeTime];
			m_fLastSwipeY = pointGl.y;
			m_dLastSwipeTime = [touch timestamp];
			
			[self rollWheel:yDelta];	// Roll the wheel				
			
			break;
		}
	}
}

- (void) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	if([touches count] == 1){		
		// Now the fun part - swipes
		m_fVelocity = [self calculateSwipeVelocity];

		if(m_fVelocity == 0.0f) m_fVelocity = 0.01f;	// Make it jump to closest anyway
		
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
		[((SongPickerMenuItem*)[m_pWheelItems objectAtIndex:i]) updateYPosition:pixels];
	}
	
	// Check last object
	float lastWheelItemY = [((SongPickerMenuItem*)[m_pWheelItems objectAtIndex:0]) getPosition].y;
	
	do {
		
		if (lastWheelItemY <= -23.0f ) {
			[m_pWheelItems removeObjectAtIndex:0];	// Will release the object
			
			// Now we must add one on top of the wheel (last element of the array)
			float firstWheelItemY = lastWheelItemY + 46.0f*kNumWheelItems;

			// Get current song on top of the wheel
			TMSong* searchSong = [((SongPickerMenuItem*)[m_pWheelItems lastObject]) song];	
			TMSong *song = [[SongsDirectoryCache sharedInstance] getSongPrevFrom:searchSong];				
			[m_pWheelItems addObject:[[SongPickerMenuItem alloc] initWithSong:song atPoint:CGPointMake(165.0f, firstWheelItemY)]];				
			
		} else if(lastWheelItemY >= 23.0f) {
			[m_pWheelItems removeLastObject];	// Will release the object
			
			// Now we must add one on the bottom of the wheel (first element of the array)
			float newLastWheelItemY = lastWheelItemY - 46.0f;
			
			// Get current song on bottom of the wheel
			TMSong* searchSong = [((SongPickerMenuItem*)[m_pWheelItems objectAtIndex:0]) song];	
			TMSong *song = [[SongsDirectoryCache sharedInstance] getSongNextTo:searchSong];				
			[m_pWheelItems insertObject:[[SongPickerMenuItem alloc] initWithSong:song atPoint:CGPointMake(165.0f, newLastWheelItemY)] atIndex:0];				
		}
		
		lastWheelItemY = [((SongPickerMenuItem*)[m_pWheelItems objectAtIndex:0]) getPosition].y;
		
	} while (lastWheelItemY < -23.0f || lastWheelItemY > 23.0f);
}

- (float) findClosest {
	float tmp = MAXFLOAT;	// Holds current minimum
	int i;
	
	for(i=kSelectedWheelItemId-2; i<kSelectedWheelItemId+2; ++i) {
		float t = [(SongPickerMenuItem*)[m_pWheelItems objectAtIndex:i] getPosition].y - 184.0f;
		if(fabsf(t) < fabsf(tmp)) { tmp = t; }
	}
	
	return tmp;
}

- (void) selectSong {
	[(TogglerItem*)m_pDifficultyToggler removeAll];
	
	SongPickerMenuItem* selected = (SongPickerMenuItem*)[m_pWheelItems objectAtIndex:kSelectedWheelItemId];
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
}

/* Handle back button */
- (void) backButtonHit {
	[[TapMania sharedInstance] switchToScreen:[[MainMenuRenderer alloc] init] usingTransition:[QuadTransition class]];
}

@end
