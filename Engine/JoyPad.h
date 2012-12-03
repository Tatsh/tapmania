//
//  $Id$
//  JoyPad.h
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMGameUIResponder.h"

@class Vector, Triangle;

typedef enum {
	kJoyButtonLeft = 0,
	kJoyButtonDown,
	kJoyButtonUp,
	kJoyButtonRight,
	kJoyButtonExit,
	kNumJoyButtons
} JPButton;

@interface JoyPad : NSObject <TMGameUIResponder> {
	BOOL		m_bAutoTrackEnabled;						// YES=enabled, NO=disabled
	
	BOOL		m_bJoyButtonStates[kNumJoyButtons]; 		// YES=touched, NO=lifted
	double		m_dJoyButtonTimeTouch[kNumJoyButtons];		// Last time every button was touched
	double		m_dJoyButtonTimeRelease[kNumJoyButtons];	// Last time every button was released

	Vector*		m_pJoyCurrentButtonLocation[kNumJoyButtons];	// Last touch location for every button
	Vector*		m_pJoyDefaultLocations[kNumJoyButtons];	
	Triangle*	m_pJoyButtons[kNumJoyButtons];
    
    float m_forceFailY;
}

@property (assign) BOOL m_bAutoTrackEnabled;

// Reset method must be called on song start
- (void) reset;
- (void) resetToDefault;

// Get state of particular button
- (BOOL) getStateForButton:(JPButton) button;
- (double) getTouchTimeForButton: (JPButton) button;
- (double) getReleaseTimeForButton: (JPButton) button;

// for iCade support
- (void) setState:(BOOL)held forButton:(JPButton) button;

- (Vector*) getJoyPadButton: (JPButton) button;
- (void) setJoyPadButton: (JPButton) button onLocation: (CGPoint) location;

@end
