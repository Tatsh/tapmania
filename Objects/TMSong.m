//
//  TMSong.m
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMSong.h"

#import "DWIParser.h"
#import "TimingUtil.h"

@implementation TMSong

@synthesize fileType, filePath, musicFilePath;
@synthesize title, artist;
@synthesize bpm, timePerBeat, gap;
@synthesize bpmChangeArray, freezeArray;

- (id) initWithStepsFile:(NSString*) lStepsFilePath andMusicFile:(NSString*) lMusicFilePath {
	
	// Note: only title etc is loaded here. No steps.
	if([lStepsFilePath hasSuffix:@".dwi"]) {
		self = [DWIParser parseFromFile:lStepsFilePath];
		self.fileType = kSongFileType_DWI;
	}
	
	self.musicFilePath = lMusicFilePath;
	self.filePath = lStepsFilePath;
	self.timePerBeat = [TimingUtil getTimeInBeat:self.bpm];
	
	NSLog(@"Time per beat: %f", self.timePerBeat);
	
	return self;
}

- (TMSteps*) getStepsForDifficulty:(TMSongDifficulty) difficulty {

	// TODO: parse real file and get data
	
	TMSteps* steps = [[TMSteps alloc] init];
	[steps addNote:[[TMNote alloc] initWithTime:1.0] toTrack:0];
	[steps addNote:[[TMNote alloc] initWithTime:2.0] toTrack:1];
	[steps addNote:[[TMNote alloc] initWithTime:3.0] toTrack:2];
	[steps addNote:[[TMNote alloc] initWithTime:4.0] toTrack:3];
	
	return steps;
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
