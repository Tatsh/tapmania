//
//  $Id$
//  TMSteps.h
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMSong.h"	// For TMSongDifficulty
#import "TMTrack.h"
#import "TMRenderable.h"
#import "TMMessageSupport.h"
#import "TMLogicUpdater.h"
#import "SongPlayRenderer.h"

@class TMTrack, TMNote, TapMine, TapNote, HoldNote, Texture2D;

typedef enum {
	kAvailableTrack_Left = 0,
	kAvailableTrack_Down,
	kAvailableTrack_Up,
	kAvailableTrack_Right,
	kNumOfAvailableTracks
} TMAvailableTracks;

#define kHitSearchEpsilon 0.185f
#define kMineHitSearchEpsilon 0.045000f	// Same as W2
#define kHoldLostEpsilon 0.5f

#define kSyncSamples 12
@class SongPlayRenderer;

@interface TMSteps : NSObject <TMRenderable, TMLogicUpdater, TMMessageSupport> {
	TMSongDifficulty	m_nDifficulty;						// The difficulty. eg. Easy, Heavy etc.
	int					m_nDifficultyLevel;					// The level. eg. 1-15.
	int					m_nTrackPos[kNumOfAvailableTracks];
	double				m_dLastHitTimes[kNumOfAvailableTracks];
	
	TMTrack*			m_pTracks[kNumOfAvailableTracks];	// We have 4 tracks which represent 4 different positions of feet
	
	/* Metrics and such */
	CGRect mt_TapNotes[kNumOfAvailableTracks];
	float  mt_TapNoteRotations[kNumOfAvailableTracks];
	CGRect mt_Receptors[kNumOfAvailableTracks];
	float mt_HalfOfArrowHeight[kNumOfAvailableTracks];
	CGSize mt_HoldCap, mt_HoldBody;
	CGPoint	mt_NotesStartPos, mt_NotesOutOfScopePos;
	
	// Noteskin stuff
	TapNote* t_TapNote;
	TapMine* t_TapMine;
	HoldNote* t_HoldNoteInactive, *t_HoldNoteActive;
	Texture2D* t_HoldBottomCapActive, *t_HoldBottomCapInactive;	
}

- (int) getDifficultyLevel;
- (void) setDifficultyLevel:(int)level;
- (TMSongDifficulty) getDifficulty;

- (void) setNote:(TMNote*) note toTrack:(int) trackIndex onNoteRow:(int) idx;
- (TMNote*) getNote:(int) index fromTrack:(int) trackIndex;
- (TMNote*) getNoteFromRow:(int) noteRow forTrack:(int) trackIndex;
- (BOOL) hasNoteAtRow:(int) noteRow forTrack:(int) trackIndex;
- (int) getNotesCountForTrack:(int) trackIndex;
- (int) getTotalNotes;

- (int) getTapAndHoldNotesCountForTrack:(int) trackIndex;
- (int) getTotalTapAndHoldNotes;

- (int) getTotalHolds;

- (BOOL) checkAllNotesHitFromRow:(int) noteRow withNoteTime:(double)inNoteTime;
- (void) markAllNotesLostFromRow:(int) noteRow;

- (int) getFirstNoteRow;
- (int) getLastNoteRow;

- (void) dump;

@end
