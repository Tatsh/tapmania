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

	// Reset states
	[self reset];

	return self;
}

/* Private constructor helpers */
- (void) createSpreadJoy {
	_joyButtons[kJoyButtonLeft] = [[Triangle alloc] 
								   initWithV0:[[Vector alloc] initWithX:160.0 andY:160.0 ]	// Center
								   V1:[[Vector alloc] initWithX:0.0 andY:320.0 ] 		// Top-left
								   andV2:[[Vector alloc] initWithX:0.0 andY:100.0 ]];	// Bottom-left
	
	_joyButtons[kJoyButtonRight] = [[Triangle alloc] 
									initWithV0:[[Vector alloc] initWithX:160.0 andY:160.0 ]	// Center
									V1:[[Vector alloc] initWithX:320.0 andY:320.0 ] 		// Top-right
									andV2:[[Vector alloc] initWithX:320.0 andY:100.0 ]];		// Bottom-right
	
	_joyButtons[kJoyButtonUp] = [[Triangle alloc] 
								 initWithV0:[[Vector alloc] initWithX:160.0 andY:160.0 ]	// Center-center
								 V1:[[Vector alloc] initWithX:160.0 andY:-90.0 ] 			// Center-bottom
								 andV2:[[Vector alloc] initWithX:416.0 andY:64.0 ]];	// Right
	
	_joyButtons[kJoyButtonDown] = [[Triangle alloc] 
								   initWithV0:[[Vector alloc] initWithX:160.0 andY:160.0 ]	// Center-center
								   V1:[[Vector alloc] initWithX:160.0 andY:-90.0 ] 		// Center-bottom
								   andV2:[[Vector alloc] initWithX:-96.0 andY:64.0 ]];	// Left
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
- (void) reset {	
	int i;
	for(i=0; i<kNumJoyButtons; ++i) {
		_joyCurrentButtonLocation[i] = nil;
		_joyButtonStates[i] = NO;
		_joyButtonTimeTouch[i] = 0.0f;
		_joyButtonTimeRelease[i] = 0.0f;
	}
}

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
			int closestButton = -1;
			float minDist = MAXFLOAT;

			Vector* v1 = [[Vector alloc] initWithX:point.x andY:point.y];
			
			for(i=0; i<kNumJoyButtons; ++i){
				
				if(_joyCurrentButtonLocation[i] != nil) {
					
					float d = [Vector distSquared:v1 and:_joyCurrentButtonLocation[i]];
					
					if(d < minDist) {
						minDist = d;
						closestButton = i;
					}

				} else {
					if([_joyButtons[i] containsPoint:point]){

						// Setup button location system
						_joyCurrentButtonLocation[i] = v1;
						closestButton = i;

						goto doneTouch;
					}
				}
			}

			[_joyCurrentButtonLocation[closestButton] release];
			_joyCurrentButtonLocation[closestButton] = v1;

			doneTouch:;	// HACK
			_joyButtonStates[closestButton] = YES;
			_joyButtonTimeTouch[closestButton] = touch.timestamp;
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
			int closestButton = -1;
			float minDist = MAXFLOAT;

			Vector* v1 = [[Vector alloc] initWithX:point.x andY:point.y];
			
			for(i=0; i<kNumJoyButtons; ++i){
				
				if(_joyCurrentButtonLocation[i] != nil) {
					
					float d = [Vector distSquared:v1 and:_joyCurrentButtonLocation[i]];
					
					if(d < minDist) {
						minDist = d;
						closestButton = i;
					}

				} else {
					if([_joyButtons[i] containsPoint:point]){

						// Setup button location system
						_joyCurrentButtonLocation[i] = v1;
						closestButton = i;
						
						goto doneRelease;
					}
				}
			}

			[_joyCurrentButtonLocation[closestButton] release];
			_joyCurrentButtonLocation[closestButton] = v1;

			doneRelease:;	// HACK
			_joyButtonStates[closestButton] = NO;
			_joyButtonTimeRelease[closestButton] = touch.timestamp;			
		}
	}
}

@end
