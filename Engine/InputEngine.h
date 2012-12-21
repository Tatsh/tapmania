//
//  $Id$
//  InputEngine.h
//  TapMania
//
//  Created by Alex Kremer on 03.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMGameUIResponder.h"
#import "TMTouch.h"

@interface InputEngine : NSObject
{
    NSMutableArray *m_aSubscribers;

    BOOL m_bDispatcherEnabled;
}

// The dispatcher can be temporarily disabled to avoid random taps from messing around
- (void)disableDispatcher;

- (void)enableDispatcher;

// One can subscribe to receive touch events by implementing the TMGameUIResponder protocol and calling subscribe method
- (void)subscribe:(id <TMGameUIResponder>)handler;

- (void)unsubscribe:(id <TMGameUIResponder>)handler;

- (void)dispatchTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)dispatchTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)dispatchTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

+ (InputEngine *)sharedInstance;

@end
