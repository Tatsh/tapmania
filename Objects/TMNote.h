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
	kNoteType_4th = 0,
	kNoteType_8th,
	kNoteType_12th,
	kNoteType_16th,
	kNoteType_24th,	
	kNoteType_32nd,	
	kNoteType_48th,	
	kNoteType_64th,	
	kNoteType_192nd,
	kNumNoteTypes,
	kNoteType_Invalid
} TMNoteType;

// Do constants instead?
#define kBeatsPerMeasure 	4
#define kRowsPerBeat 		48
#define kRowsPerMeasure		kRowsPerBeat*kBeatsPerMeasure

@interface TMNote : NSObject {
	float				beat;		// The beat on which this note should fire
	float				tillBeat;	// If the note is a hold note - this var points to the end beat of the hold
	TMNoteType			type;		// Type of the note (1/4, 1/8...etc)
	
	BOOL		isHit;		// True if the note was hit during gameplay
	double		hitTime;	// The time in milliseconds when the player hit the note (offset from start of song)
}

@property (assign, readonly) float beat;
@property (assign, readonly) float tillBeat;
@property (assign, readonly) TMNoteType type;

@property (assign, readonly) BOOL isHit;
@property (assign, readonly) double hitTime;

- (id) initWithBeat:(float) lBeat tillBeat:(float) lTillBeat;

- (void) hit:(double)lHitTime;

+ (TMNoteType) getNoteType:(int) row;
+ (TMNoteType) beatToNoteType:(float) fBeat;
+ (int) beatToNoteRow:(float) fBeat;

@end
