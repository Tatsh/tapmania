//
//  $Id$
//  TMNote.h
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "Judgement.h"
#import "TMSteps.h"

typedef enum {
	kNoteDirection_Left = 0,
	kNoteDirection_Down,
	kNoteDirection_Up,
	kNoteDirection_Right,
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
	kNoteType_Mine,
	kNumNoteTypes
} TMNoteType;

typedef enum {
	kHoldScore_OK = 0,
	kHoldScore_NG,
	kNumHoldScores
} TMHoldScore;

// Do constants instead?
#define kNotesPerMeasureRow 4
#define kBeatsPerMeasure 	4
#define kRowsPerBeat 		48
#define kRowsPerMeasure		192 // 4x48

@interface TMNote : NSObject {

	TMBeatType			m_nBeatType;	// Type of the beat (1/4, 1/8...etc)
	TMNoteType			m_nType;		// Type of the note
	
	int					m_nStartNoteRow;	// Start note row in the track
	int					m_nStopNoteRow;		// For hold notes
	TMAvailableTracks	m_nTrack;
	
	BOOL		m_bIsHit;			// True if the note was hit during gameplay
	BOOL		m_bMultiHit;		// If this note must be hit with other notes on same noteRow
	BOOL		m_bIsLost;			// True if the note was not hit in the timing window
	BOOL		m_bIsHolding;
	BOOL		m_bIsHeld;		// True if the note is hit and held till end
	BOOL		m_bIsHoldLost;	// True if the hold is lost
	BOOL		m_bIsMineHit;
	BOOL		m_bIsMineAvoided;
	
	double		m_dHitTime;					// The time in milliseconds when the player hit the note (offset from start of song)
	double		m_dTimeTillHit;				// Time in milliseconds till the ideal hit time (updated constantly during gameplay)
	double		m_dLastHoldTouchTime;		// Last time when the player layed his finger on the hold arrow
	double		m_dLastHoldReleaseTime;	// Last time when the player raised his finger from the hold
	
	// The TMNote object is aware of current Y position on screen
	float		m_fStartYPosition;
	float		m_fStopYPosition;
	
	// Scoring info
	TMTimingFlag	m_nTimingFlag;
	TMJudgement		m_nScore;
	TMHoldScore		m_nHoldScore;
}

@property (assign, readonly) TMAvailableTracks m_nTrack;
@property (assign) int m_nStartNoteRow;
@property (assign) int m_nStopNoteRow;
@property (assign, readonly) TMBeatType m_nBeatType;
@property (assign) TMNoteType m_nType;

@property (assign, readonly) BOOL m_bIsHit;
@property (assign, readonly) BOOL m_bMultiHit;
@property (assign, readonly) BOOL m_bIsLost;
@property (assign, readonly) BOOL m_bIsHolding;
@property (assign, readonly) BOOL m_bIsHeld;
@property (assign, readonly) BOOL m_bIsHoldLost;
@property (assign, readonly) BOOL m_bIsMineHit;
@property (assign, readonly) BOOL m_bIsMineAvoided;

@property (assign, readonly) double m_dHitTime;
@property (assign, readwrite) double m_dTimeTillHit;
@property (assign, readonly) double m_dLastHoldTouchTime;
@property (assign, readonly) double m_dLastHoldReleaseTime;

// System info for drawing
@property (assign) float m_fStartYPosition;
@property (assign) float m_fStopYPosition;

// Scoring info
@property (assign, readonly) TMJudgement m_nScore;
@property (assign, readonly) TMTimingFlag m_nTimingFlag;
@property (assign, readonly) TMHoldScore m_nHoldScore;

- (id) initWithNoteRow:(int) noteRow andType:(TMNoteType)type onTrack:(TMAvailableTracks)inTrack;

- (void) hit:(double)hitTime;

- (void) mineHit;
- (void) mineAvoided;

- (void) score:(TMJudgement)score withTimingFlag:(TMTimingFlag)timingFlag;

- (void) startHolding:(double)touchTime;
- (void) stopHolding:(double)releaseTime;

- (void) markLost;
- (void) markHoldLost;
- (void) markHoldHeld;

+ (TMBeatType) getBeatType:(int) row;
+ (int) beatToNoteRow:(float) beat;
+ (float) noteRowToBeat:(int) noteRow;

@end
