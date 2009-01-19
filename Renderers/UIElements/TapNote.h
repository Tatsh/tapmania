//
//  TapNote.h
//  TapMania
//
//  Created by Alex Kremer on 05.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMAnimatable.h"
#import "TMNote.h"

/*
 * This class represents every original tap note on screen.
 * The tap note is actually a texture object with animation which is used by the songPlayRenderer and TMNote for rendering.
 * All notes on screen will be animated at the same time so one TapNote object is enough for all original tap notes on screen.
*/
@interface TapNote : TMAnimatable {
	
}

// Drawing routines
- (void) drawTapNote:(TMBeatType)type direction:(TMNoteDirection)dir inRect:(CGRect)rect;
- (void) drawHoldTapNote:(TMBeatType)type direction:(TMNoteDirection)dir inRect:(CGRect)rect;

@end
