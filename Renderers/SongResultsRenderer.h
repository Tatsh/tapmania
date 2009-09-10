//
//  SongResultsRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 21.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMNote.h" // For kNumNoteScores etc.

#import "TMRenderable.h"
#import "TMLogicUpdater.h"
#import "TMTransitionSupport.h"
#import "TMGameUIResponder.h"

@class TMSteps, TMSong;

@interface SongResultsRenderer : NSObject <TMRenderable, TMLogicUpdater, TMTransitionSupport, TMGameUIResponder> {
	TMSong*					m_pSong;	// The song we are calculating for
	TMSteps*				m_pSteps;	// The steps we played
	
	int						m_nCounters[kNumNoteScores];
	int						m_nOkNgCounters[kNumHoldScores];
	
	BOOL					m_bReturnToSongSelection;
	
	NSMutableArray* texturesArray;
}

- (id) initWithSong:(TMSong*)song withSteps:(TMSteps*)steps;

@end
