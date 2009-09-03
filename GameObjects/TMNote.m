//
//  TMNote.m
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMNote.h"


@implementation TMNote

@synthesize m_nType, m_nBeatType, m_bIsHit, m_bIsLost, m_bIsHeld, m_dHitTime, m_bIsHolding, m_bIsHoldLost, m_nScore, m_nHoldScore;
@synthesize m_dLastHoldTouchTime, m_dLastHoldReleaseTime, m_nStartNoteRow, m_nStopNoteRow, m_fStartYPosition, m_fStopYPosition;

- (id) initWithNoteRow:(int) noteRow andType:(TMNoteType)type {
	self = [super init];
	if(!self)
		return nil;
	
	m_nStartNoteRow = noteRow;
	m_nStopNoteRow = -1;
	m_nBeatType = [TMNote getBeatType:noteRow];
	m_nType = type;
	
	m_bIsLost = NO;
	m_bIsHit = NO;
	m_bIsHolding = NO;
	m_bIsHeld = NO;
	m_bIsHoldLost = NO;
	m_dHitTime = 0.0f;
	
	m_fStartYPosition = 0.0f;
	m_fStopYPosition = 0.0f;
	
	m_nScore = kNoteScore_None;	// No scoring info by default
	m_nHoldScore = kHoldScore_NG;	// NG by default
	
	return self;
}

- (void) hit:(double)hitTime {
	if(!m_bIsHit){
		m_bIsHit = YES;
		m_dHitTime = hitTime;
	}
}

- (void) markLost {
	m_bIsLost = YES;
}

- (void) score:(TMNoteScore)score { 
	m_nScore = score;
}

- (void) startHolding:(double)touchTime {
	m_dLastHoldTouchTime = touchTime;
	m_bIsHolding = YES;
	m_bIsHeld = YES; // Will be set to NO if released
	m_bIsHoldLost = NO;

	m_nHoldScore = kHoldScore_OK;
}

- (void) stopHolding:(double)releaseTime {
	m_dLastHoldReleaseTime = releaseTime;
	m_bIsHolding = NO;
}

- (void) markHoldLost {
	m_bIsHolding = NO;
	m_bIsHeld = NO;
	m_bIsHoldLost = YES;
	
	m_nHoldScore = kHoldScore_NG;
}

+ (TMBeatType) getBeatType:(int) row {
	if(row % (kRowsPerMeasure/4) == 0)	return kBeatType_4th;
	if(row % (kRowsPerMeasure/8) == 0)	return kBeatType_8th;
	if(row % (kRowsPerMeasure/12) == 0)	return kBeatType_12th;
	if(row % (kRowsPerMeasure/16) == 0)	return kBeatType_16th;
	if(row % (kRowsPerMeasure/24) == 0)	return kBeatType_24th;
	if(row % (kRowsPerMeasure/32) == 0)	return kBeatType_32nd;
	if(row % (kRowsPerMeasure/48) == 0)	return kBeatType_48th;
	if(row % (kRowsPerMeasure/64) == 0)	return kBeatType_64th;
	return kBeatType_192nd;
}

+ (float) noteRowToBeat:(int) noteRow {
	return noteRow / (float)kRowsPerBeat;
}

+ (int) beatToNoteRow:(float) beat {
	return lrintf( beat * kRowsPerBeat );	
}

@end
