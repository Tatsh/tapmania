//
//  JoyPad.h
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

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

/*
 This delegate can be used to notify your controller about changes in the joypad (button press/release)
 */
@protocol JoyPadControllerDelegate <NSObject>
- (void) joyPadStatusUpdated;
@end

@interface JoyPad : UIView {
	BOOL _joyButtonStates[kNumJoyButtons]; // YES=touched, NO=lifted
	CGRect _tapZones[kNumJoyButtons];      // Where the button tap zones are on the screen
	UIButton* _buttons[kNumJoyButtons];    // The actual buttons
	
	id delegate; // Controller delegate
}

@property (assign) id <JoyPadControllerDelegate> delegate;

// The constructor
- (id) initWithStyle:(JPStyle)style andFrame:(CGRect)frame;

// Get state of particular button
- (BOOL) getStateForButton:(JPButton) button;

// Press and Release buttons in the joypad
- (void) gotPress:(id) sender;
- (void) gotRelease:(id) sender;

@end
