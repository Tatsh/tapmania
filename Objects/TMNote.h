//
//  TMNote.h
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TMNote : NSObject {
	double	time;		// The time when this note should fire
	double	tillTime;	// If the note is a hold note - this var points to the end time of the note
	int		beatType;	// Type of the note's beat (1/4, 1/8...etc)
}

@property (assign, readonly) double time;

- (id) initWithTime:(double) lTime tillTime:(double) lTillTime;

@end
