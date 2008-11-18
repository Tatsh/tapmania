//
//  TMNote.h
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	kNoteDirection_Left = 0,
	kNoteDirection_Right,
	kNoteDirection_Down,
	kNoteDirection_Up,
	kNumNoteDirections
} TMNoteDirection;

typedef enum {
	kBeatType_4th = 0,
	kBeatType_8th,
	kBeatType_12th,
	kBeatType_16th,
	kBeatType_24th,	
	kBeatType_32nd,	
	kBeatType_48th,	
	kBeatType_64th,	
	kBeatType_192nd,
	kNumBeatTypes,
	kBeatType_Invalid
} TMBeatType;

typedef enum {
	kNoteType_Empty = 0,
	kNoteType_Original,
	kNoteType_HoldHead,
	kNumNoteTypes
} TMNoteType;

// Do constants instead?
#define kBeatsPerMeasure 	4
#define kRowsPerBeat 		48
#define kRowsPerMeasure		kRowsPerBeat*kBeatsPerMeasure

@interface TMNote : NSObject {
	float				beat;		// The beat on which this note should fire
	float				tillBeat;	// If the note is a hold note - this var points to the end beat of the hold
	TMBeatType			beatType;	// Type of the beat (1/4, 1/8...etc)
	TMNoteType			type;		// Type of the note
	
	int					index;		// Index of this note in the track
	
	BOOL		isHit;		// True if the note was hit during gameplay
	double		hitTime;	// The time in milliseconds when the player hit the note (offset from start of song)
}

@property (assign) int index;
@property (assign, readonly) float beat;
@property (assign) float tillBeat;
@property (assign, readonly) TMBeatType beatType;
@property (assign) TMNoteType type;

@property (assign, readonly) BOOL isHit;
@property (assign, readonly) double hitTime;

- (id) initWithBeat:(float) lBeat andType:(TMNoteType)lType;

- (void) hit:(double)lHitTime;

+ (TMBeatType) getBeatType:(int) row;
+ (TMBeatType) beatToBeatType:(float) fBeat;
+ (int) beatToNoteRow:(float) fBeat;

@end
