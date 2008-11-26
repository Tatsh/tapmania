//
//  JoyPad.m
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <syslog.h>

#import "JoyPad.h"
#import "TimingUtil.h"

@interface JoyPad (Private)
- (void) createSpreadJoy;
- (void) createIndexJoy;
@end


@implementation JoyPad

@synthesize delegate;

- (id) initWithStyle:(JPStyle)style {
	switch (style) {
		case kJoyStyleIndex:
			self = [super initWithFrame:CGRectMake(60, 280, 200, 200)];			
			[self createIndexJoy];
			break;
		case kJoyStyleSpread:
		default:
			self = [super initWithFrame:CGRectMake(0, 300, 320, 180)];
			[self createSpreadJoy];
			break;
	}
	
	[self setBackgroundColor:[UIColor clearColor]]; // Make the view background transparent	
	
	return self;
}

/* Private constructor helpers */
- (void) createSpreadJoy {
	int i;
	
	// Create and init buttons
	UIImage* image = nil;
	
	int spacingBetweenButtons = 6;
	
	int buttonWidth = self.frame.size.width / 4 - 8;
	int buttonHeight = self.frame.size.height - 12;
	
	int curXOffset = 6; // Initial offset
	
	NSString* imgNames[kNumJoyButtons] = {@"arrow-left.png", @"arrow-down.png", @"arrow-up.png", @"arrow-right.png"};
	
	for (i=0; i<kNumJoyButtons; i++){
		UIButton* but = [[UIButton alloc] initWithFrame:CGRectMake(curXOffset, 6, buttonWidth, buttonHeight)];
		image = [[UIImage imageNamed:imgNames[i]] retain];
		
		[but setBackgroundImage:image forState:UIControlStateNormal];
		
		_joyButtonStates[i] = NO;
		_joyButtonTimeTouch[i] = 0.0f;
		_joyButtonTimeRelease[i] = 0.0f;
		_buttons[i] = but;
		
		// Bind button touch/realease stuff
		[_buttons[i] addTarget:self action:@selector(gotPress:) forControlEvents:
		 UIControlEventTouchDown|UIControlEventTouchDragEnter];
		[_buttons[i] addTarget:self action:@selector(gotRelease:) forControlEvents:
		 UIControlEventTouchCancel|UIControlEventTouchDragExit|UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
		
		// Add buton to the joypad
		[self addSubview:_buttons[i]];
		
		[image release];
		curXOffset += (buttonWidth+spacingBetweenButtons);
	}	
}

- (void) createIndexJoy {
	int i;
	
	// Create and init buttons
	UIImage* image = nil;
	
	int buttonWidth = self.frame.size.width / 3;
	int buttonHeight = self.frame.size.height / 3;
	
	// Left, down, up, right
	int buttonX[kNumJoyButtons] = {0, buttonWidth, buttonWidth, buttonWidth*2};
	int buttonY[kNumJoyButtons] = {buttonHeight, buttonHeight*2, 0, buttonHeight };
	NSString* imgNames[kNumJoyButtons] = {@"arrow-left.png", @"arrow-down.png", @"arrow-up.png", @"arrow-right.png"};
	
	for (i=0; i<kNumJoyButtons; i++){
		UIButton* but = [[UIButton alloc] initWithFrame:CGRectMake(buttonX[i], buttonY[i], buttonWidth, buttonHeight)];
		image = [[UIImage imageNamed:imgNames[i]] retain];
		
		[but setBackgroundImage: image forState:UIControlStateNormal];
		
		_joyButtonStates[i] = NO;
		_joyButtonTimeTouch[i] = 0.0f;
		_joyButtonTimeRelease[i] = 0.0f;
		_buttons[i] = but;
		
		// Bind button touch/realease stuff
		[_buttons[i] addTarget:self action:@selector(gotPress:) forControlEvents:
		 UIControlEventTouchDown|UIControlEventTouchDragEnter];
		[_buttons[i] addTarget:self action:@selector(gotRelease:) forControlEvents:
		 UIControlEventTouchCancel|UIControlEventTouchDragExit|UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
		
		// Add buton to the joypad
		[self addSubview:_buttons[i]];
		
		[image release];
	}	
}

/* Public methods */
- (BOOL) getStateForButton: (JPButton) button {
	return _joyButtonStates[button];
}

- (double) getTouchTimeForButton: (JPButton) button {
	return _joyButtonTimeTouch[button];
}

- (double) getReleaseTimeForButton: (JPButton) button {
	return _joyButtonTimeRelease[button];
}

- (void) gotPress:(id) sender {
	int i;

	for(i=0; i<kNumJoyButtons; i++) {
		if(sender == _buttons[i]){
			// Found button id
			_joyButtonStates[i] = YES;
			_joyButtonTimeTouch[i] = [TimingUtil getCurrentTime];
			
			return;
		}
	}
}

- (void) gotRelease:(id) sender {
	int i;

	for(i=0; i<kNumJoyButtons; i++) {
		if(sender == _buttons[i]){
			// Found button id
			_joyButtonStates[i] = NO;
			_joyButtonTimeRelease[i] = [TimingUtil getCurrentTime];
			
			return;
		}
	}	
}


@end
