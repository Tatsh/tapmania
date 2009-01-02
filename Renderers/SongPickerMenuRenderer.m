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

#import "TexturesHolder.h"
#import "TapManiaAppDelegate.h"
#import "SongsDirectoryCache.h"
#import "TimingUtil.h"

#import "MainMenuRenderer.h"

#import "SongPickerMenuItem.h"
#import "SongPickerMenuSelectedItem.h"

#import "SongPlayRenderer.h"

#define kMinSwipeDelta 50.0f
#define	kMinSwipeTime 0.1f
#define kSelectedWheelItemId 2

@interface SongPickerMenuRenderer (Private)

- (void) shiftWheelBy:(float)items;
- (void) playSong;

@end


@implementation SongPickerMenuRenderer

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	/*
	NSArray* songList = [[SongsDirectoryCache sharedInstance] getSongList];
		
	for(i=0; i<[songList count]; i++){
		TMSong *song = [songList objectAtIndex:i];
	
		syslog(LOG_DEBUG, "available difficulties:");
		TMSongDifficulty dif = kSongDifficulty_Invalid;
		
		for(; dif < kNumSongDifficulties; dif++) {
			if([song isDifficultyAvailable:dif]) {
	//			syslog(LOG_DEBUG, "%s [%d]", [[TMSong difficultyToString:dif] UTF8String], [song getDifficultyLevel:dif]);
			}
		}		
	}
	*/
	
	scrollVelocity = 0.0f;
	moveRows = 0;
	startSongPlay = NO;
	
	CGRect bounds = [TapMania sharedInstance].glView.bounds;
	NSArray* songList = [[SongsDirectoryCache sharedInstance] getSongList];
	
	float curWidth = 0.85f;	// 95% - 2*5% = 85% = 0.85
	float curYOffset = -39.0f;
	float curXOffset;
	
	float curIncrementer = 0.05;
	
	int i;
	int j = 0;
	
	for(i=0; i<kNumWheelItems; i++){
		
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
			wheelItems[i] = [[SongPickerMenuItem alloc] initWithSong:song andShape:CGRectMake(curXOffset, curYOffset, curWidth*bounds.size.width, curHeight)];

		} else if (i==kSelectedWheelItemId){
			
			// Save current song id
			currentSongId = j;
			
			curWidth = 0.95;
			curYOffset += curHeight;
			curXOffset = bounds.size.width - curWidth*bounds.size.width;
			wheelItems[i] = [[SongPickerMenuSelectedItem alloc] initWithSong:song andShape:CGRectMake(curXOffset, curYOffset, curWidth*bounds.size.width, 118.0f)];

			// Size difference
			curYOffset += 76.0f;
			
		} else {
			
			curIncrementer += 0.01;
			curYOffset += curHeight+2;
			curWidth -= curIncrementer;
			curXOffset = bounds.size.width - curWidth*bounds.size.width;
			wheelItems[i] = [[SongPickerMenuItem alloc] initWithSong:song andShape:CGRectMake(curXOffset, curYOffset, curWidth*bounds.size.width, curHeight)];
		}
	}
	
	return self;
}

/* TMTransitionSupport methods */
- (void) setupForTransition {
	// Subscribe for input events
	[[InputEngine sharedInstance] subscribe:self];
}

- (void) deinitOnTransition {
	// Unsubscribe from input events
	[[InputEngine sharedInstance] unsubscribe:self];
}

/* TMRenderable method */
- (void) render:(NSNumber*)fDelta {
	CGRect bounds = [TapMania sharedInstance].glView.bounds;
	
	// Draw menu background
	glDisable(GL_BLEND);
	[[[TexturesHolder sharedInstance] getTexture:kTexture_SongSelectionBackground] drawInRect:bounds];
	glEnable(GL_BLEND);
	
	// Positions of the wheel items are fixed
	int i;
	for(i=0; i<kNumWheelItems; i++){
		[wheelItems[i] render:fDelta];
	}
}

/* TMLogicUpdater stuff */
- (void) update:(NSNumber*)fDelta {
	
	// Check whether we should start playing
	if(startSongPlay){
		
		TMSongOptions* options = [[TMSongOptions alloc] init];
		
		// Assign speed modifier
		[options setSpeedMod:kSpeedMod_2x]; 
		
		// Assign difficulty
		[options setDifficulty:kSongDifficulty_Hard];
		
		SongPlayRenderer* songPlayRenderer = [[SongPlayRenderer alloc] init];
		[songPlayRenderer playSong:wheelItems[kSelectedWheelItemId].song withOptions:options];
		
		[[TapMania sharedInstance] switchToScreen:songPlayRenderer];
		
		startSongPlay = NO;	// Ensure we are doing this only once
	}
	
	// Do all scroll related stuff
	if(fabsf(scrollVelocity) > 0.05f){
		scrollVelocity -= [fDelta floatValue]*scrollVelocity;
	} else {

		// Stop scroll
		scrollVelocity = 0.0f;
	}
	
	moveRows += scrollVelocity/10.0f;
	if(fabsf(moveRows) >= 1.0f) {
		// Time to shift
		[self shiftWheelBy:moveRows];
		
		moveRows = 0;
	}
}

/* TMGameUIResponder methods */
- (void) tmTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	// Handle wheel
	switch ([touches count]) {
		case 1:
		{
			UITouch* touch = [touches anyObject];
			startTouchPos = [touch locationInView:[TapMania sharedInstance].glView];
			startTouchTime = [TimingUtil getCurrentTime];
			
			lastTouchPos = startTouchPos;
			lastMoveTime = startTouchTime;
			
			scrollVelocity = 0.0f;	// Stop scrollin if touching the screen
			
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
	
			moveRows = (pos.y-lastTouchPos.y)/40.0f; // 40.0f is about the size of the wheel item
			if(fabsf(moveRows) >= 1.0f) {
				lastTouchPos = pos;
			}
			
			lastMoveTime = [TimingUtil getCurrentTime];
			
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
		if([t1 tapCount] > 1 && [wheelItems[kSelectedWheelItemId] containsPoint:pointGl]){
			[self playSong];
			return;
		}
		
		// Now the fun part - swipes
		float deltaX = fabsf(startTouchPos.x - pos.x);
		
		float curTime = [TimingUtil getCurrentTime];
		
		// Check vertical swipes only
		if(deltaX <= kMinSwipeDelta && curTime-lastMoveTime <= kMinSwipeTime) {
			float timeDelta = [TimingUtil getCurrentTime] - startTouchTime;
			scrollVelocity = (pos.y-startTouchPos.y)/400.0f/timeDelta; // 400.0f is about one full wheel drag actually
		}
	}
}


/* Private method */
- (void) shiftWheelBy:(float)items {
	int i, j;
	NSArray* songList = [[SongsDirectoryCache sharedInstance] getSongList];

	j = currentSongId-kSelectedWheelItemId+items;
	if(j < 0) j = [songList count]+j;
	
	for(i=0; i<kNumWheelItems; i++){
		
		if(j >= [songList count]) {
			j = 0;
		}
		
		if(i == kSelectedWheelItemId) currentSongId = j;		
		[wheelItems[i] switchToSong:[songList objectAtIndex:j++]];
	}
}

- (void) playSong {
	if(wheelItems[kSelectedWheelItemId] != nil) {
		TMSong* song = wheelItems[kSelectedWheelItemId].song;
		if(song != nil) {
			startSongPlay = YES;
		}
	}
}

@end
