//
//  JoyPad.m
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <syslog.h>

#import "JoyPad.h"

@implementation JoyPad

@synthesize delegate;

- (id) initWithStyle:(JPStyle)style andFrame:(CGRect)lFrame {
	self = [super initWithFrame:lFrame];
	
	if(!self) 
		return nil;
	
	// Create and init buttons
	UIImage* image = nil;
	
	int spacingBetweenButtons = 6;
	
	int buttonWidth = lFrame.size.width / 4 - 8;
	int buttonHeight = lFrame.size.height - 12;
	
	int curXOffset = 6; // Initial offset
	
	NSString* imgNames[kNumJoyButtons] = {@"arrow-left.png", @"arrow-down.png", @"arrow-up.png", @"arrow-right.png"};
	
	for (int i=0; i<kNumJoyButtons; i++){
		UIButton* but = [[UIButton alloc] initWithFrame:CGRectMake(curXOffset, 6, buttonWidth, buttonHeight)];
		image = [[UIImage imageNamed:imgNames[i]] retain];
		
		[but setTitle:@"but" forState:UIControlStateNormal];
		[but setImage: image forState:UIControlStateNormal];
		
		_joyButtonStates[i] = NO;
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
	
	// FIXME: Style is only spread by now.
	[self setBackgroundColor:[UIColor clearColor]]; // Make the view background transparent	
	
	return self;
}

- (BOOL) getStateForButton: (JPButton) button {
	return _joyButtonStates[button];
}

- (void) gotPress:(id) sender {
	for(int i=0; i<kNumJoyButtons; i++) {
		if(sender == _buttons[i]){
			// Found button id
			_joyButtonStates[i] = YES;
			
			// Let the delegate know about the status update
			[delegate joyPadStatusUpdated];		
			
			return;
		}
	}
}

- (void) gotRelease:(id) sender {
	for(int i=0; i<kNumJoyButtons; i++) {
		if(sender == _buttons[i]){
			// Found button id
			_joyButtonStates[i] = NO;
			
			// Let the delegate know about the status update
			[delegate joyPadStatusUpdated];		
			
			return;
		}
	}	
}


@end
