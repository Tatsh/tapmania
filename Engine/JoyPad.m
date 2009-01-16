//
//  JoyPad.m
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <syslog.h>

#import "JoyPad.h"
#import "TapMania.h"
#import "TimingUtil.h"

@interface JoyPad (Private)
- (void) createSpreadJoy;
- (void) createIndexJoy;
@end


@implementation JoyPad

- (id) initWithStyle:(JPStyle)style {
	self = [super init];
	if(!self)
		return nil;

	switch (style) {
		case kJoyStyleIndex:
			[self createIndexJoy];
			break;
		case kJoyStyleSpread:
		default:
			[self createSpreadJoy];
			break;
	}
	
	return self;
}

/* Private constructor helpers */
- (void) createSpreadJoy {
	// TODO
}

- (void) createIndexJoy {
	// We have a 320x320 joypad
	//
	//	*     *
	//     *
	//  *     *
	
	_joyButtons[kJoyButtonLeft] = [[Triangle alloc] 
		initWithV0:[[Vector alloc] initWithX:160.0 andY:160.0 ]	// Center
		V1:[[Vector alloc] initWithX:0.0 andY:320.0 ] 		// Top-left
		andV2:[[Vector alloc] initWithX:0.0 andY:0.0 ]];	// Bottom-left

	_joyButtons[kJoyButtonRight] = [[Triangle alloc] 
		initWithV0:[[Vector alloc] initWithX:160.0 andY:160.0 ]	// Center
		V1:[[Vector alloc] initWithX:320.0 andY:320.0 ] 		// Top-right
		andV2:[[Vector alloc] initWithX:320.0 andY:0.0 ]];		// Bottom-right

	_joyButtons[kJoyButtonUp] = [[Triangle alloc] 
		initWithV0:[[Vector alloc] initWithX:160.0 andY:160.0 ]	// Center
		V1:[[Vector alloc] initWithX:0.0 andY:320.0 ] 			// Top-left
		andV2:[[Vector alloc] initWithX:320.0 andY:320.0 ]];	// Top-Right

	_joyButtons[kJoyButtonDown] = [[Triangle alloc] 
		initWithV0:[[Vector alloc] initWithX:160.0 andY:160.0 ]	// Center
		V1:[[Vector alloc] initWithX:0.0 andY:0.0 ] 		// Bottom-left
		andV2:[[Vector alloc] initWithX:320.0 andY:0.0 ]];	// Bottom-right
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

/* TMGameUIResponder methods */
- (void) tmTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	int touchIdx;
	
	for(touchIdx=0; touchIdx<[touches count]; ++touchIdx) {
		UITouch * touch = [[touches allObjects] objectAtIndex:touchIdx];		
		CGPoint point = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:
						 [touch locationInView:[TapMania sharedInstance].glView]];
		
		// Check general touch position
		if(point.y <= 320.0) {
			int i;
			
			for(i=0; i<kNumJoyButtons; ++i){
				if([_joyButtons[i] containsPoint:point]){
					_joyButtonStates[i] = YES;
					_joyButtonTimeTouch[i] = touch.timestamp; 
				}
			}
		}
	}
}

/*
- (void) tmTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	[self tmTouchesBegan:touches withEvent:event];
}
*/

- (void) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	int touchIdx;

	for(touchIdx=0; touchIdx<[touches count]; ++touchIdx) {
		UITouch * touch = [[touches allObjects] objectAtIndex:touchIdx];
		CGPoint point = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:
						 [touch locationInView:[TapMania sharedInstance].glView]];

		// Check general touch position
		if(point.y <= 320.0) {
			int i;
			
			for(i=0; i<kNumJoyButtons; ++i){
				if([_joyButtons[i] containsPoint:point]){
					_joyButtonStates[i] = NO;
					_joyButtonTimeRelease[i] = touch.timestamp;
				}
			}
		}
	}
}

@end
