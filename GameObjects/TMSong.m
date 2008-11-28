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
@synthesize bpm, gap;
@synthesize bpmChangeArray, freezeArray;

- (id) initWithStepsFile:(NSString*) lStepsFilePath andMusicFile:(NSString*) lMusicFilePath {
	
	// Note: only title etc is loaded here. No steps.
	if([lStepsFilePath hasSuffix:@".dwi"]) {
		self = [DWIParser parseFromFile:lStepsFilePath];
		self.fileType = kSongFileType_DWI;
	}
	
	self.musicFilePath = lMusicFilePath;
	self.filePath = lStepsFilePath;

	// Set the bpm for song start
	NSMutableArray* songBpmChangeArray = self.bpmChangeArray;
	self.bpmChangeArray = [[NSMutableArray alloc] initWithObjects: [[TMChangeSegment alloc] initWithNoteRow:0.0f andValue:self.bpm/60.0f] ,nil];

	int i;
	for(i=0; i<[songBpmChangeArray count]; i++){
		TMChangeSegment* segment = [songBpmChangeArray objectAtIndex:i];
		segment.changeValue = segment.changeValue/60.0f;
		
		[self.bpmChangeArray addObject:segment];
	}
	
	[songBpmChangeArray release];
	
	return self;
}

- (TMSteps*) getStepsForDifficulty:(TMSongDifficulty) difficulty {

	TMSteps* steps = [DWIParser parseStepsFromFile:self.filePath 
				forDifficulty:difficulty forSong:self];	

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
