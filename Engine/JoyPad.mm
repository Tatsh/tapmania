//
//  JoyPad.m
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "JoyPad.h"
#import "TapMania.h"
#import "SettingsEngine.h"
#import "TimingUtil.h"
#import "PhysicsUtil.h"
#import "EAGLView.h"
#import "TMMessage.h"
#import "MessageManager.h"

@interface JoyPad (Private)
- (void) createSpreadJoy;
- (void) createIndexJoy;
@end


@implementation JoyPad

@synthesize m_bAutoTrackEnabled;

- (id) init {
	self = [super init];
	if(!self)
		return nil;

	// Register message types
	REG_MESSAGE(kJoyPadTapMessage, @"PadTap");
	REG_MESSAGE(kJoyPadReleaseMessage, @"PadRelease");
	
	m_pJoyDefaultLocations[kJoyButtonLeft] =  [[Vector alloc] initWithX:70 andY:122];
	m_pJoyDefaultLocations[kJoyButtonDown] =  [[Vector alloc] initWithX:160 andY:62];
	m_pJoyDefaultLocations[kJoyButtonUp] =    [[Vector alloc] initWithX:160 andY:182];
	m_pJoyDefaultLocations[kJoyButtonRight] = [[Vector alloc] initWithX:250 andY:122];
	m_pJoyDefaultLocations[kJoyButtonExit] =  nil;
	
	// Reset states (to saved if any)
	[self reset];
	
	// Restore config value of autoTracking feature
	m_bAutoTrackEnabled =	CFG_BOOL(@"autotrack");

	return self;
}

/* Public methods */
- (void) reset {	
	int i;
	for(i=0; i<kNumJoyButtons; ++i) {
		// Check whether we have a value in config or not
		CGPoint buttonPoint = [[SettingsEngine sharedInstance] getJoyPadButton:(JPButton)i];
		
		if(m_pJoyCurrentButtonLocation[i]) 
			[m_pJoyCurrentButtonLocation[i] release];		
		
		if(buttonPoint.x != -1 && buttonPoint.y != -1) {
			m_pJoyCurrentButtonLocation[i] = [[Vector alloc] initWithX:buttonPoint.x andY:buttonPoint.y];
		} else {
			// Set default value for this button
			m_pJoyCurrentButtonLocation[i] = [[Vector alloc] initWithX:m_pJoyDefaultLocations[i].m_fX andY:m_pJoyDefaultLocations[i].m_fY];
		}
		
		if(m_pJoyCurrentButtonLocation[i] != nil) {
			// Save into config
			[[SettingsEngine sharedInstance] setJoyPadButtonPosition:CGPointMake(m_pJoyCurrentButtonLocation[i].m_fX, m_pJoyCurrentButtonLocation[i].m_fY) forButton:(JPButton)i];
		}
		
		m_bJoyButtonStates[i] = NO;
		m_dJoyButtonTimeTouch[i] = 0.0f;
		m_dJoyButtonTimeRelease[i] = 0.0f;
	}
}

- (void) resetToDefault {
	for(int i=0; i<kNumJoyButtons; ++i) {
		if(m_pJoyCurrentButtonLocation[i]) 
			[m_pJoyCurrentButtonLocation[i] release];
		
		m_pJoyCurrentButtonLocation[i] = [[Vector alloc] initWithX:m_pJoyDefaultLocations[i].m_fX andY:m_pJoyDefaultLocations[i].m_fY];
		if(m_pJoyCurrentButtonLocation[i] != nil) {
			[[SettingsEngine sharedInstance] setJoyPadButtonPosition:CGPointMake(m_pJoyCurrentButtonLocation[i].m_fX, m_pJoyCurrentButtonLocation[i].m_fY) forButton:(JPButton)i];
		}
	}
}

- (Vector*) getJoyPadButton: (JPButton) button {
	return m_pJoyCurrentButtonLocation[button];
}

- (void) setJoyPadButton: (JPButton) button onLocation: (CGPoint) location {
	// Save in the settings
	[[SettingsEngine sharedInstance] setJoyPadButtonPosition:location forButton:button];
	
	// Update locally
	if(m_pJoyCurrentButtonLocation[button]) {
		[(m_pJoyCurrentButtonLocation[button]) release];
	}
	m_pJoyCurrentButtonLocation[button] = [[Vector alloc] initWithX:location.x andY:location.y];
}

- (BOOL) getStateForButton: (JPButton) button {
	return m_bJoyButtonStates[button];
}

- (double) getTouchTimeForButton: (JPButton) button {
	return m_dJoyButtonTimeTouch[button];
}

- (double) getReleaseTimeForButton: (JPButton) button {
	return m_dJoyButtonTimeRelease[button];
}

/* TMGameUIResponder methods */
- (BOOL) tmTouchesBegan:(const TMTouchesVec&)touches withEvent:(UIEvent*)event {
	int touchIdx;
	
	for(touchIdx=0; touchIdx<touches.size(); ++touchIdx) {
		TMTouch touch = touches.at(touchIdx);
		CGPoint point = CGPointMake(touch.x(), touch.y());
		
		// Check general touch position
		if(point.y >= 420.0) {
			// This means we want to exit the song (force fail)
			m_bJoyButtonStates[kJoyButtonExit] = YES;
			m_dJoyButtonTimeTouch[kJoyButtonExit] = touch.timestamp();
			BROADCAST_MESSAGE(kJoyPadTapMessage, [NSNumber numberWithInt:kJoyButtonExit]);
			
		} else {
			int i;
			int closestButton = -1;
			float minDist = MAXFLOAT;

			Vector* v1 = [[Vector alloc] initWithX:point.x andY:point.y];
			
			for(i=0; i<kNumJoyButtons; ++i){
				if(i == kJoyButtonExit)
					continue;
				
				float d = [Vector distSquared:v1 And:m_pJoyCurrentButtonLocation[i]];
					
				if(d < minDist) {
					minDist = d;
					closestButton = i;
				}
			}

			if(m_bAutoTrackEnabled == YES) {
				// Store new position if we are using the autotrack feature
				[m_pJoyCurrentButtonLocation[closestButton] release];
				m_pJoyCurrentButtonLocation[closestButton] = v1;
			}

			m_bJoyButtonStates[closestButton] = YES;
			m_dJoyButtonTimeTouch[closestButton] = touch.timestamp();
			BROADCAST_MESSAGE(kJoyPadTapMessage, [NSNumber numberWithInt:closestButton]);
		}
	}
	
	return NO; // Always pretend as of we didn't receive the touches
}

- (BOOL) tmTouchesMoved:(const TMTouchesVec&)touches withEvent:(UIEvent*)event {
// 	[self tmTouchesBegan:touches withEvent:event];
	return false;
}

- (BOOL) tmTouchesEnded:(const TMTouchesVec&)touches withEvent:(UIEvent*)event {
	int touchIdx;

	for(touchIdx=0; touchIdx<touches.size(); ++touchIdx) {
		TMTouch touch = touches.at(touchIdx);
		CGPoint point = CGPointMake(touch.x(), touch.y());
		
		int i;
		int closestButton = -1;
		float minDist = MAXFLOAT;

		Vector* v1 = [[Vector alloc] initWithX:point.x andY:point.y];
			
		for(i=0; i<kNumJoyButtons; ++i){
			if(i == kJoyButtonExit)
				continue;
			
			float d = [Vector distSquared:v1 And:m_pJoyCurrentButtonLocation[i]];
					
			if(d < minDist) {
				minDist = d;
				closestButton = i;
			}
		}

		if(m_bAutoTrackEnabled == YES) {
			// Store new position if we are using the autotrack feature
			[m_pJoyCurrentButtonLocation[closestButton] release];
			m_pJoyCurrentButtonLocation[closestButton] = v1;
		}
		
		m_bJoyButtonStates[closestButton] = NO;
		m_dJoyButtonTimeRelease[closestButton] = touch.timestamp();			
		BROADCAST_MESSAGE(kJoyPadReleaseMessage, [NSNumber numberWithInt:closestButton]);
	}
	
	return NO;
}

@end
