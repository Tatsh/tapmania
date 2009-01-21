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
	TMSong*					song;	// The song we are calculating for
	TMSteps*				steps;	// The steps we played
	
	int						counters[kNumNoteScores];
	int						okNgCounters[kNumHoldScores];
	
	BOOL					returnToSongSelection;
	
	NSMutableArray* texturesArray;
}

- (id) initWithSong:(TMSong*)lSong withSteps:(TMSteps*)lSteps;

@end
