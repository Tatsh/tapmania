//
//  TMSong.h
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	kSongDifficulty_Beginer = 0,
	kSongDifficulty_Easy,
	kSongDifficulty_Standard,
	kSongDifficulty_Heavy,
	kSongDifficulty_Challenge,
	kNumSongDifficulties
} TMSongDifficulty;

#import "TMSteps.h"

@class TMSteps;

@interface TMSong : NSObject {
	
	// Song information
	NSString * artist;
	NSString * title;
	NSString * description;

	int _availableDifficultyLevels[kNumSongDifficulties];	// Every difficulty which is available is set to the difficulty level (1+). set to -1 otherwise.
}

@property (retain, nonatomic) NSString* artist;
@property (retain, nonatomic) NSString* title;
@property (retain, nonatomic) NSString* description;


// The constructor which is used. will parse the original stepmania file to determine song info.
- (id) initWithFile:(NSString*) filename;

- (TMSteps*) getStepsForDifficulty:(TMSongDifficulty) difficulty;

- (BOOL) isDifficultyAvailable:(TMSongDifficulty) difficulty;
- (int)  getDifficultyLevel:(TMSongDifficulty) difficulty;

+ (NSString*) difficultyToString:(TMSongDifficulty)difficulty;

@end
