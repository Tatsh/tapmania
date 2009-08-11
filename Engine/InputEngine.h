//
//  InputEngine.h
//  TapMania
//
//  Created by Alex Kremer on 03.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputEngine : NSObject {
	NSMutableArray * m_aSubscribers;
	
	NSObject	   * m_pDialog;
	BOOL			 m_bDispatcherEnabled;
}

// The dispatcher can be temporarily disabled to avoid random taps from messing around
- (void) disableDispatcher;
- (void) enableDispatcher;

// One can subscribe to receive touch events by implementing the TMGameUIResponder protocol and calling subscribe method
- (void) subscribe:(NSObject*) handler;
- (void) subscribeDialog:(NSObject*) handler;
- (void) unsubscribe:(NSObject*) handler;

- (void) dispatchTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;
- (void) dispatchTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event;
- (void) dispatchTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;

+ (InputEngine *)sharedInstance;

@end
