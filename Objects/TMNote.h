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

	TMBeatType			beatType;	// Type of the beat (1/4, 1/8...etc)
	TMNoteType			type;		// Type of the note
	
	int					startNoteRow;	// Start note row in the track
	int					stopNoteRow;	// For hold notes
	
	BOOL		isHit;		// True if the note was hit during gameplay
	BOOL		isHeld;		// True if the note is hit and held till end
	double		hitTime;	// The time in milliseconds when the player hit the note (offset from start of song)
	double		lastHoldReleaseTime;	// Last time when the player raised his finger from the hold
}

@property (assign) int startNoteRow;
@property (assign) int stopNoteRow;
@property (assign, readonly) TMBeatType beatType;
@property (assign) TMNoteType type;

@property (assign, readonly) BOOL isHit;
@property (assign, readonly) BOOL isHeld;

@property (assign, readonly) double hitTime;
@property (assign, readonly) double lastHoldReleaseTime;

- (id) initWithNoteRow:(int) noteRow andType:(TMNoteType)lType;

- (void) hit:(double)lHitTime;

+ (TMBeatType) getBeatType:(int) row;
+ (int) beatToNoteRow:(float) fBeat;
+ (float) noteRowToBeat:(int) noteRow;

@end
