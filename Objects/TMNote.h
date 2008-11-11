//
//  TMNote.h
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	kBeatType_1 = 0,
	kBeatType_2,
	kBeatType_4,
	kBeatType_8,
	kBeatType_16,
	kBeatType_24,
	kBeatType_64,
	kBeatType_192
} TMBeatType;


@interface TMNote : NSObject {
	double		time;		// The time when this note should fire
	double		tillTime;	// If the note is a hold note - this var points to the end time of the note
	TMBeatType	beatType;	// Type of the note's beat (1/4, 1/8...etc)
	
	BOOL		isHit;		// True if the note was hit during gameplay
	double		hitTime;	// The time in milliseconds when the player hit the note (offset from start of song)
}

@property (assign, readonly) double time;
@property (assign, readonly) double tillTime;
@property (assign, readonly) TMBeatType beatType;

@property (assign, readonly) BOOL isHit;
@property (assign, readonly) double hitTime;

- (id) initWithTime:(double) lTime tillTime:(double) lTillTime;

- (void) hit:(double)lHitTime;

@end
