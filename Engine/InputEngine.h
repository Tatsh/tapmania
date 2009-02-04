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
}

// One can subscribe to receive touch events by implementing the TMGameUIResponder protocol and calling subscribe method
- (void) subscribe:(NSObject*) handler;
- (void) unsubscribe:(NSObject*) handler;

- (void) dispatchTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;
- (void) dispatchTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event;
- (void) dispatchTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;

+ (InputEngine *)sharedInstance;

@end
