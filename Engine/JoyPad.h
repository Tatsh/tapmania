//
//  JoyPad.h
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMGameUIResponder.h"
#import "PhysicsUtil.h"

typedef enum {
	kJoyButtonLeft = 0,
	kJoyButtonDown,
	kJoyButtonUp,
	kJoyButtonRight,
	kNumJoyButtons
} JPButton;

typedef enum {
	kJoyStyleSpread = 0,
	kJoyStyleIndex
} JPStyle;

@interface JoyPad : NSObject <TMGameUIResponder> {
	BOOL _joyButtonStates[kNumJoyButtons]; 		// YES=touched, NO=lifted
	double _joyButtonTimeTouch[kNumJoyButtons];	// Last time every button was touched
	double _joyButtonTimeRelease[kNumJoyButtons];	// Last time every button was released

	Vector* _joyCurrentButtonLocation[kNumJoyButtons];	// Last touch location for every button
	Triangle* _joyButtons[kNumJoyButtons];
}

// The constructor
- (id) initWithStyle:(JPStyle)style;

// Reset method must be called on song start
- (void) reset;

// Get state of particular button
- (BOOL) getStateForButton:(JPButton) button;
- (double) getTouchTimeForButton: (JPButton) button;
- (double) getReleaseTimeForButton: (JPButton) button;

@end
