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
#define kSelectedWheelItemId 4

@interface SongPickerMenuRenderer (Private)

- (void) saveSwipeElement:(float)value;
- (float) calculateSwipeVelocity;
- (void) clearSwipes;

- (void) rollWheel:(float) pixels;

@end


static int mt_SpeedTogglerX, mt_SpeedTogglerY, mt_SpeedTogglerWidth, mt_SpeedTogglerHeight;


@implementation SongPickerMenuRenderer

Texture2D* t_SongPickerBG;
Texture2D* t_Highlight;

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
	
	m_pWheelItems = [[NSMutableArray alloc] initWithCapacity:kNumWheelItems];
	NSArray* songList = [[SongsDirectoryCache sharedInstance] getSongList];
	
	m_fVelocity = 0.0f;
	m_fAcceleration = 5.0f;
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
	
	// 184.0f -- the position of the highlight element
	
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

- (void) dealloc {
	[m_pWheelItems removeAllObjects];
	[m_pWheelItems release];
	[m_pSpeedToggler release];
	
	[super dealloc];
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
	for(i=0; i<[m_pWheelItems count]; i++){
		[(SongPickerMenuItem*)[m_pWheelItems objectAtIndex:i] render:fDelta];
	}
	
	// Highlight selection
	glEnable(GL_BLEND);
	[t_Highlight drawAtPoint:CGPointMake(165.0f, 184.0f)];
	glDisable(GL_BLEND);
	
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
		[songPlayRenderer playSong:((SongPickerMenuItem*)[m_pWheelItems objectAtIndex:kSelectedWheelItemId]).m_pSong withOptions:options];
		
		[[TapMania sharedInstance] switchToScreen:songPlayRenderer];
		
		m_bStartSongPlay = NO;	// Ensure we are doing this only once
	}
	
	// Do all scroll related stuff
	if(m_fVelocity != 0.0f) {
		
		m_fVelocity -= [fDelta floatValue] * m_fAcceleration;
		
		if(m_fVelocity <= 0.0f) {
			// Stop scrolling
			m_fVelocity = 0.0f;
			
		} else {
			[self rollWheel: [fDelta floatValue] * m_fVelocity * m_fSwipeDirection];
			TMLog(@"Current velocity %f with direction %f", m_fVelocity, m_fSwipeDirection);
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
			
			[self saveSwipeElement:pointGl.y-m_fLastSwipeY];
			m_fLastSwipeY = pointGl.y;
			
			break;
		}
	}
}

- (void) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	UITouch *t1 = [[touches allObjects] objectAtIndex:0];
	
	if([touches count] == 1){
		
		CGPoint pos = [t1 locationInView:[TapMania sharedInstance].glView];
		CGPoint pointGl = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:pos];
		[self saveSwipeElement:pointGl.y-m_fLastSwipeY];		
		
		// Now the fun part - swipes
		m_fVelocity = [self calculateSwipeVelocity];
		TMLog(@"Got swipe velocity: %f", m_fVelocity);
		
		[self clearSwipes];
	}
}

- (void) clearSwipes {	
	int i;
	for(i=0; i<kNumSwipePositions; ++i) {
		m_fSwipeBuffer[i] = 0.0f;
	}
	
	m_nCurrentSwipePosition = 0;
	m_fLastSwipeY = 0.0f;
}	

- (float) calculateSwipeVelocity {
	int i;
	float total = 0.0f;	
	
	for(i=0; i<kNumSwipePositions; ++i) {
		total += m_fSwipeBuffer[i];
	}
	
	total /= kNumSwipePositions;
	total *= 10.0f;
	
	if(total <= 0.0f) {
		m_fSwipeDirection = -1.0f;
		return fabsf(total);
	}
	
	m_fSwipeDirection = 1.0f;
	return total;
}

- (void) saveSwipeElement:(float)value {
	if(m_nCurrentSwipePosition == kNumSwipePositions-1) {
		m_nCurrentSwipePosition = 0;
	}
	
	m_fSwipeBuffer[m_nCurrentSwipePosition++] = value;
}

- (void) rollWheel:(float) pixels {
	int i;
	for(i=0; i<[m_pWheelItems count]; ++i) {
		[((SongPickerMenuItem*)[m_pWheelItems objectAtIndex:i]) updateYPosition:pixels];
	}
	
	// Check last object
	if ( [((SongPickerMenuItem*)[m_pWheelItems objectAtIndex:0]) getPosition].y <= -23.0f ) {
		TMLog(@"Time to remove element from bottom top of list");
	}
}

@end
