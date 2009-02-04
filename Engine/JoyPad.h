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
	BOOL		m_bJoyButtonStates[kNumJoyButtons]; 		// YES=touched, NO=lifted
	double		m_dJoyButtonTimeTouch[kNumJoyButtons];		// Last time every button was touched
	double		m_dJoyButtonTimeRelease[kNumJoyButtons];	// Last time every button was released

	Vector*		m_pJoyCurrentButtonLocation[kNumJoyButtons];	// Last touch location for every button
	Triangle*	m_pJoyButtons[kNumJoyButtons];
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
