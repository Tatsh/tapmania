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
#import "TMRenderable.h"
#import "TMTransitionSupport.h"
#import "TMGameUIResponder.h"

#import "SongPickerMenuItem.h"

#define kNumWheelItems 7

@interface SongPickerMenuRenderer : NSObject <TMLogicUpdater, TMRenderable, TMTransitionSupport, TMGameUIResponder> {
	SongPickerMenuItem* wheelItems[kNumWheelItems]; // Always 7 wheel items are visible on screen
	int currentSongId;	// Selected song index
	
	float scrollVelocity;	// Current velocity of the wheel scroll if moving. -values is down, +values is up
	float moveRows;
	
	CGPoint startTouchPos;
}

@end
