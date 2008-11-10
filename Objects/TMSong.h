//
//  TMSong.h
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	kSongDifficulty_Invalid = 0,
	kSongDifficulty_Beginner,
	kSongDifficulty_Easy,
	kSongDifficulty_Medium,
	kSongDifficulty_Hard,
	kSongDifficulty_Challenge,
	kNumSongDifficulties
} TMSongDifficulty;

#import "TMSteps.h"

@class TMSteps;

@interface TMSong : NSObject {
	
	// Song information
	NSString* 	title;
	NSString* 	artist;
	float	  	bpm;
	unsigned long 	gap;
	
	NSMutableArray* bpmChangeArray;
	NSMutableArray* freezeArray;

	int _availableDifficultyLevels[kNumSongDifficulties];	// Every difficulty which is available is set to the difficulty level (1+). set to -1 otherwise.
}

@property (retain, nonatomic) NSString* artist;
@property (retain, nonatomic) NSString* title;
@property (assign) float bpm;
@property (assign) unsigned long gap;
@property (retain, nonatomic) NSMutableArray* bpmChangeArray;
@property (retain, nonatomic) NSMutableArray* freezeArray;

// The constructor which is used. will parse the original stepmania file to determine song info.
- (id) initWithFile:(NSString*) filename;

- (TMSteps*) getStepsForDifficulty:(TMSongDifficulty) difficulty;

- (BOOL) isDifficultyAvailable:(TMSongDifficulty) difficulty;
- (int)  getDifficultyLevel:(TMSongDifficulty) difficulty;
- (void) enableDifficulty:(TMSongDifficulty) difficulty withLevel:(int) level;

+ (NSString*) difficultyToString:(TMSongDifficulty)difficulty;

@end
