//
//  TMTimeBasedChange.h
//  TapMania
//
//  Created by Alex Kremer on 13.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMBeatBasedChange : NSObject {
	float	beat;			// The beat when this change should fire
	float	changeValue;	// The value to change to
}

@property (assign, readonly) float beat;
@property (assign, readonly) float changeValue;

- (id) initWithBeat:(float) lBeat andValue:(float) lValue;

@end
