//
//  TMSteps.h
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMSong.h"

@interface TMSteps : NSObject {
	TMSongDifficulty difficulty;	// The difficulty. eg. Easy, Heavy etc.
	int difficultyLevel;			// The level. eg. 1-15.
	
	// TODO: define structures to hold the actual step data
}

// The constructor which is used. will parse the original stepmania file to determine steps info for the given level.
- (id) initWithFile:(NSString*) filename;

- (int) getDifficultyLevel;
- (TMSongDifficulty) getDifficulty;

// TODO: define routines to work with the actual step data in the structures

@end
