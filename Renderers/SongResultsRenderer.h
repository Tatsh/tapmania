//
//  SongResultsRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 21.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMSteps.h"
#import "TMSong.h"
#import "TMLogicUpdater.h"
#import "AbstractRenderer.h"
#import "TMTransitionSupport.h"
#import "TMGameUIResponder.h"

@interface SongResultsRenderer : AbstractRenderer <TMLogicUpdater, TMTransitionSupport, TMGameUIResponder> {
	TMSong*					m_pSong;	// The song we are calculating for
	TMSteps*				m_pSteps;	// The steps we played
	
	int						m_nCounters[kNumNoteScores];
	int						m_nOkNgCounters[kNumHoldScores];
	
	BOOL					m_bReturnToSongSelection;
	
	NSMutableArray* texturesArray;
}

- (id) initWithSong:(TMSong*)song withSteps:(TMSteps*)steps;

@end
