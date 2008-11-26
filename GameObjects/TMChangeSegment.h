//
//  TMChangeSegment.h
//  TapMania
//
//  Created by Alex Kremer on 13.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMChangeSegment : NSObject {
	float	noteRow;		// The noteRow when this change should fire
	float	changeValue;	// The value to change to
}

@property (assign, readonly) float noteRow;
@property (assign) float changeValue;

- (id) initWithNoteRow:(int) lNoteRow andValue:(float) lValue;

@end
