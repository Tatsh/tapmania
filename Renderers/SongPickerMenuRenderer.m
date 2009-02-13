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

#import "SongPickerMenuItem.h"
#import "SongPickerMenuSelectedItem.h"
#import "TogglerItem.h"

#import "InputEngine.h"
#import "TapMania.h"
#import "EAGLView.h"
#import "ThemeManager.h"

#import "SongPlayRenderer.h"

#define kMinSwipeDelta 50.0f
#define	kMinSwipeTime 0.1f
#define kSelectedWheelItemId 2

@interface SongPickerMenuRenderer (Private)

- (void) shiftWheelBy:(float)items;
- (void) playSong;

@end


static int mt_SpeedTogglerX, mt_SpeedTogglerY, mt_SpeedTogglerWidth, mt_SpeedTogglerHeight;


@implementation SongPickerMenuRenderer

Texture2D* t_SongPickerBG;

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
	
	/*
	NSArray* songList = [[SongsDirectoryCache sharedInstance] getSongList];
		
	for(i=0; i<[songList count]; i++){
		TMSong *song = [songList objectAtIndex:i];
	
		TMLog(@"available difficulties:");
		TMSongDifficulty dif = kSongDifficulty_Invalid;
		
		for(; dif < kNumSongDifficulties; dif++) {
			if([song isDifficultyAvailable:dif]) {
	//			TMLog(@"%s [%d]", [TMSong difficultyToString:dif], [song getDifficultyLevel:dif]);
			}
		}		
	}
	*/
	
	m_fScrollVelocity = 0.0f;
	m_fMoveRows = 0;
	m_bStartSongPlay = NO;
	
	CGRect bounds = [TapMania sharedInstance].glView.bounds;
	NSArray* songList = [[SongsDirectoryCache sharedInstance] getSongList];
		
	float curWidth = 0.85f;	// 95% - 2*5% = 85% = 0.85
	float curYOffset = -39.0f;
	float curXOffset;
	
	float curIncrementer = 0.05;
	
	int i;
	int j = 0;
	
	for(i=0; i<kNumWheelItems; i++) {
		
		if(j == [songList count]) {
			j = 0;
		}

		TMSong *song = [songList objectAtIndex:j++];
		
		float curHeight = 40.0f;
		
		if(i<kSelectedWheelItemId){
			curIncrementer -= 0.01;
			curWidth += curIncrementer;
			curYOffset += curHeight+2;
			curXOffset = bounds.size.width - curWidth*bounds.size.width;
			m_pWheelItems[i] = [[SongPickerMenuItem alloc] initWithSong:song andShape:CGRectMake(curXOffset, curYOffset, curWidth*bounds.size.width, curHeight)];

		} else if (i==kSelectedWheelItemId){
			
			// Save current song id
			m_nCurrentSongId = j;
			
			curWidth = 0.95;
			curYOffset += curHeight;
			curXOffset = bounds.size.width - curWidth*bounds.size.width;
			m_pWheelItems[i] = [[SongPickerMenuSelectedItem alloc] initWithSong:song andShape:CGRectMake(curXOffset, curYOffset, curWidth*bounds.size.width, 118.0f)];

			// Size difference
			curYOffset += 76.0f;
			
		} else {
			
			curIncrementer += 0.01;
			curYOffset += curHeight+2;
			curWidth -= curIncrementer;
			curXOffset = bounds.size.width - curWidth*bounds.size.width;
			m_pWheelItems[i] = [[SongPickerMenuItem alloc] initWithSong:song andShape:CGRectMake(curXOffset, curYOffset, curWidth*bounds.size.width, curHeight)];
		}
	}
	
	NSArray* arr = [NSArray arrayWithObjects:
					[[TogglerItemObject alloc] initWithTitle:[TMSongOptions speedModAsString:kSpeedMod_1x] andValue:[NSNumber numberWithInt:kSpeedMod_1x]],
					[[TogglerItemObject alloc] initWithTitle:[TMSongOptions speedModAsString:kSpeedMod_1_5x] andValue:[NSNumber numberWithInt:kSpeedMod_1_5x]], 
					[[TogglerItemObject alloc] initWithTitle:[TMSongOptions speedModAsString:kSpeedMod_2x] andValue:[NSNumber numberWithInt:kSpeedMod_2x]],
					[[TogglerItemObject alloc] initWithTitle:[TMSongOptions speedModAsString:kSpeedMod_3x] andValue:[NSNumber numberWithInt:kSpeedMod_3x]],
					[[TogglerItemObject alloc] initWithTitle:[TMSongOptions speedModAsString:kSpeedMod_5x] andValue:[NSNumber numberWithInt:kSpeedMod_5x]],
					[[TogglerItemObject alloc] initWithTitle:[TMSongOptions speedModAsString:kSpeedMod_8x] andValue:[NSNumber numberWithInt:kSpeedMod_8x]], nil];
	m_pSpeedToggler = [[TogglerItem alloc] initWithElements:arr andShape:CGRectMake(255, 375, 60, 40)];
	
	return self;
}

/* TMTransitionSupport methods */
- (void) setupForTransition {
	// Subscribe for input events
	[[InputEngine sharedInstance] subscribe:self];
	[[InputEngine sharedInstance] subscribe:m_pSpeedToggler];
}

- (void) deinitOnTransition {
	// Unsubscribe from input events
	[[InputEngine sharedInstance] unsubscribe:self];
	[[InputEngine sharedInstance] unsubscribe:m_pSpeedToggler];
}

/* TMRenderable method */
- (void) render:(NSNumber*)fDelta {
	CGRect bounds = [TapMania sharedInstance].glView.bounds;
	
	// Draw menu background
	[t_SongPickerBG drawInRect:bounds];
	
	// Positions of the wheel items are fixed
	int i;
	for(i=0; i<kNumWheelItems; i++){
		[m_pWheelItems[i] render:fDelta];
	}
	
	[m_pSpeedToggler render:fDelta];
}

/* TMLogicUpdater stuff */
- (void) update:(NSNumber*)fDelta {
	
	// Check whether we should start playing
	if(m_bStartSongPlay){
		
		TMSongOptions* options = [[TMSongOptions alloc] init];
		
		// Assign speed modifier
		[options setSpeedMod:[(NSNumber*)[m_pSpeedToggler getCurrent].m_pValue intValue]]; 
		
		// Assign difficulty
		[options setDifficulty:kSongDifficulty_Hard];
		
		SongPlayRenderer* songPlayRenderer = [[SongPlayRenderer alloc] init];
		[songPlayRenderer playSong:m_pWheelItems[kSelectedWheelItemId].m_pSong withOptions:options];
		
		[[TapMania sharedInstance] switchToScreen:songPlayRenderer];
		
		m_bStartSongPlay = NO;	// Ensure we are doing this only once
	}
	
	// Do all scroll related stuff
	if(fabsf(m_fScrollVelocity) > 0.05f){
		m_fScrollVelocity -= [fDelta floatValue]*m_fScrollVelocity;
	} else {

		// Stop scroll
		m_fScrollVelocity = 0.0f;
	}
	
	m_fMoveRows += m_fScrollVelocity/10.0f;
	if(fabsf(m_fMoveRows) >= 1.0f) {
		// Time to shift
		[self shiftWheelBy:m_fMoveRows];
		
		m_fMoveRows = 0;
	}
}

/* TMGameUIResponder methods */
- (void) tmTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	// Handle wheel
	switch ([touches count]) {
		case 1:
		{
			UITouch* touch = [touches anyObject];
			m_oStartTouchPos = [touch locationInView:[TapMania sharedInstance].glView];
			m_fStartTouchTime = [TimingUtil getCurrentTime];
			
			m_oLastTouchPos = m_oStartTouchPos;
			m_fLastMoveTime = m_fStartTouchTime;
			
			m_fScrollVelocity = 0.0f;	// Stop scrollin if touching the screen
			
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
	
			m_fMoveRows = (pos.y-m_oLastTouchPos.y)/40.0f; // 40.0f is about the size of the wheel item
			if(fabsf(m_fMoveRows) >= 1.0f) {
				m_oLastTouchPos = pos;
			}
			
			m_fLastMoveTime = [TimingUtil getCurrentTime];
			
			break;
		}
	}
}

- (void) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	UITouch *t1 = [[touches allObjects] objectAtIndex:0];
	
	if([touches count] == 1){
		
		CGPoint pos = [t1 locationInView:[TapMania sharedInstance].glView];
		CGPoint pointGl = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:pos];
		
		// Should start a song?
		if([t1 tapCount] > 1 && [m_pWheelItems[kSelectedWheelItemId] containsPoint:pointGl]){
			[self playSong];
			return;
		}
		
		// Now the fun part - swipes
		float deltaX = fabsf(m_oStartTouchPos.x - pos.x);
		
		float curTime = [TimingUtil getCurrentTime];
		
		// Check vertical swipes only
		if(deltaX <= kMinSwipeDelta && curTime-m_fLastMoveTime <= kMinSwipeTime) {
			float timeDelta = [TimingUtil getCurrentTime] - m_fStartTouchTime;
			m_fScrollVelocity = (pos.y-m_oStartTouchPos.y)/400.0f/timeDelta; // 400.0f is about one full wheel drag actually
		}
	}
}


/* Private method */
- (void) shiftWheelBy:(float)items {
	int i, j;
	NSArray* songList = [[SongsDirectoryCache sharedInstance] getSongList];

	j = m_nCurrentSongId-kSelectedWheelItemId+items;
	if(j < 0) j = [songList count]+j;
	
	for(i=0; i<kNumWheelItems; i++){
		
		if(j >= [songList count]) {
			j = 0;
		}
		
		if(i == kSelectedWheelItemId) m_nCurrentSongId = j;		
		[m_pWheelItems[i] switchToSong:[songList objectAtIndex:j++]];
	}
}

- (void) playSong {
	if(m_pWheelItems[kSelectedWheelItemId] != nil) {
		TMSong* song = m_pWheelItems[kSelectedWheelItemId].m_pSong;
		if(song != nil) {
			m_bStartSongPlay = YES;
		}
	}
}

@end
