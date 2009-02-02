//
//  SongPickerMenuRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 07.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InputEngine.h"
#import "TMLogicUpdater.h"
#import "TMTransitionSupport.h"
#import "TMGameUIResponder.h"

#import "SongPickerMenuItem.h"
#import "AbstractRenderer.h"
#import "TogglerItem.h"

#define kNumWheelItems 7

@interface SongPickerMenuRenderer : AbstractRenderer <TMLogicUpdater, TMTransitionSupport, TMGameUIResponder> {
	TogglerItem* speedToggler;
	
	SongPickerMenuItem* wheelItems[kNumWheelItems]; // Always 7 wheel items are visible on screen
	int currentSongId;	// Selected song index
	
	float scrollVelocity;	// Current velocity of the wheel scroll if moving. -values is down, +values is up
	float moveRows;
	
	CGPoint startTouchPos;
	float startTouchTime;
	
	CGPoint lastTouchPos;
	float lastMoveTime;
	
	BOOL startSongPlay;
}

@end
