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
	kBeatType_1_2,
	kBeatType_1_4,
	kBeatType_1_8,
	kBeatType_1_16,
	kBeatType_1_24,
	kBeatType_1_64,
	kBeatType_1_192
} TMBeatType;


@interface TMNote : NSObject {
	float				beat;		// The beat on which this note should fire
	float				tillBeat;	// If the note is a hold note - this var points to the end beat of the hold
	TMBeatType			beatType;	// Type of the note's beat (1/4, 1/8...etc)
	
	BOOL		isHit;		// True if the note was hit during gameplay
	double		hitTime;	// The time in milliseconds when the player hit the note (offset from start of song)
}

@property (assign, readonly) float beat;
@property (assign, readonly) float tillBeat;
@property (assign, readonly) TMBeatType beatType;

@property (assign, readonly) BOOL isHit;
@property (assign, readonly) double hitTime;

- (id) initWithBeat:(float) lBeat tillBeat:(float) lTillBeat;

- (void) hit:(double)lHitTime;

@end
