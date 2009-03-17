//
//  InputEngine.m
//  TapMania
//
//  Created by Alex Kremer on 03.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "InputEngine.h"
#import "TMGameUIResponder.h"

// This is a singleton class, see below
static InputEngine *sharedInputEngineDelegate = nil;

@implementation InputEngine

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	m_aSubscribers = [[NSMutableArray alloc] initWithCapacity:5];
	m_bDispatcherEnabled = YES;
	
	return self;
}

- (void) dealloc {
	[m_aSubscribers release];
	[super dealloc];
}

- (void) disableDispatcher {
	m_bDispatcherEnabled = NO;
}

- (void) enableDispatcher { 
	m_bDispatcherEnabled = YES;
}

- (void) subscribe:(NSObject*) handler {
	if([handler conformsToProtocol:@protocol(TMGameUIResponder)]){
		[m_aSubscribers addObject:handler];
	} else {
		TMLog(@"Passed an object which doesn't conform to TMGameUIResponder protocol. ignore.");
	}
}

- (void) unsubscribe:(NSObject*) handler {
	// Will remove the handler if found
	[m_aSubscribers removeObject:handler];
}

- (void) dispatchTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	if(m_bDispatcherEnabled) {
		int i;
		for(i=0; i<[m_aSubscribers count]; i++){
			NSObject* handler = [m_aSubscribers objectAtIndex:i];
			if([handler respondsToSelector:@selector(tmTouchesBegan:withEvent:)]){
				[handler performSelector:@selector(tmTouchesBegan:withEvent:) withObject:touches withObject:event];
			}
		}
	}
}

- (void) dispatchTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	if(m_bDispatcherEnabled) {
		int i;
		for(i=0; i<[m_aSubscribers count]; i++){
			NSObject* handler = [m_aSubscribers objectAtIndex:i];
			if([handler respondsToSelector:@selector(tmTouchesMoved:withEvent:)]){
				[handler performSelector:@selector(tmTouchesMoved:withEvent:) withObject:touches withObject:event];
			}
		}	
	}
}

- (void) dispatchTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	if(m_bDispatcherEnabled) {
		int i;
		for(i=0; i<[m_aSubscribers count]; i++){
			NSObject* handler = [m_aSubscribers objectAtIndex:i];
			if([handler respondsToSelector:@selector(tmTouchesEnded:withEvent:)]){
				[handler performSelector:@selector(tmTouchesEnded:withEvent:) withObject:touches withObject:event];
			}
		}	
	}
}

#pragma mark Singleton stuff

+ (InputEngine *)sharedInstance {
    @synchronized(self) {
        if (sharedInputEngineDelegate == nil) {
            [[self alloc] init];
        }
    }
    return sharedInputEngineDelegate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedInputEngineDelegate	== nil) {
            sharedInputEngineDelegate = [super allocWithZone:zone];
            return sharedInputEngineDelegate;
        }
    }
	
    return nil;
}


- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
	// NOTHING
}

- (id)autorelease {
    return self;
}


@end
