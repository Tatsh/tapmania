//
//  TMTimeBasedChange.h
//  TapMania
//
//  Created by Alex Kremer on 13.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMTimeBasedChange : NSObject {
	double		time;		// The time when this change should fire
	double		changeValue;		// The value to change to
}

@property (assign, readonly) double time;
@property (assign, readonly) double changeValue;

- (id) initWithTime:(double) lTime andValue:(double) lValue;

@end
