//
//  TMSong.m
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMSong.h"


@implementation TMSong

@synthesize title, artist;
@synthesize bpm, gap;
@synthesize bpmChangeArray, freezeArray;

- (id) initWithFile:(NSString*) filename {
	self = [super init];
	if(!self)
		return nil;
	
	// TODO: parse song
	// Note: only title etc is loaded here. No steps.
	
	return self;
}

- (TMSteps*) getStepsForDifficulty:(TMSongDifficulty) difficulty {
	// TODO impl
	return nil;
}

- (BOOL) isDifficultyAvailable:(TMSongDifficulty) difficulty {
	if(difficulty < kNumSongDifficulties && _availableDifficultyLevels[difficulty] != kSongDifficulty_Invalid) 
		return YES;
	return NO;
}

- (int)  getDifficultyLevel:(TMSongDifficulty) difficulty {
	if([self isDifficultyAvailable:difficulty])
		return _availableDifficultyLevels[difficulty];
	
	return -1;
}

- (void) enableDifficulty:(TMSongDifficulty) difficulty withLevel:(int) level {
	_availableDifficultyLevels[difficulty] = level;
}

+ (NSString*) difficultyToString:(TMSongDifficulty)difficulty {
	switch (difficulty) {
		case kSongDifficulty_Beginner:
			return @"Beginner";
		case kSongDifficulty_Easy:
			return @"Easy";
		case kSongDifficulty_Medium:
			return @"Standard";
		case kSongDifficulty_Hard:
			return @"Heavy";
		case kSongDifficulty_Challenge:
			return @"Challenge";
		default:
			return @"UNKNOWN";
	}
}

@end
