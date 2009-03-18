//
//  TMSong.m
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMSong.h"

#import "DWIParser.h"
#import "SMParser.h"

#import "TimingUtil.h"
#import "TMChangeSegment.h"

@implementation TMSong

@synthesize m_nFileType, m_sFilePath, m_sMusicFilePath;
@synthesize m_sTitle, m_sArtist;
@synthesize m_fBpm, m_dGap;
@synthesize m_aBpmChangeArray, m_aFreezeArray;

- (id) initWithStepsFile:(NSString*) stepsFilePath andMusicFile:(NSString*) musicFilePath {
	
	// Note: only title etc is loaded here. No steps.
	if([[stepsFilePath lowercaseString] hasSuffix:@".dwi"]) {
		self = [DWIParser parseFromFile:stepsFilePath];
		self.m_nFileType = kSongFileType_DWI;
	} else if([[stepsFilePath lowercaseString] hasSuffix:@".sm"]) {
		self = [SMParser parseFromFile:stepsFilePath];	
		self.m_nFileType = kSongFileType_SM;
	} else {
		TMLog(@"Some unknown format...");
		return nil;
	}

	// ERROR HERE! FIXME
	self.m_sMusicFilePath = musicFilePath;
	self.m_sFilePath = stepsFilePath;
	
	// Set the bpm for song start
	TMLog(@"Bpm stuff");
	NSMutableArray* songBpmChangeArray = self.m_aBpmChangeArray;
	self.m_aBpmChangeArray = [[NSMutableArray alloc] initWithObjects: [[TMChangeSegment alloc] initWithNoteRow:0.0f andValue:self.m_fBpm/60.0f] ,nil];

	int i;
	for(i=0; i<[songBpmChangeArray count]; i++){
		TMChangeSegment* segment = [songBpmChangeArray objectAtIndex:i];
		segment.m_fChangeValue = segment.m_fChangeValue/60.0f;
		
		[self.m_aBpmChangeArray addObject:segment];
	}
	
	TMLog(@"Done bpm stuff");
	
	[songBpmChangeArray release];
	
	return self;
}

- (TMSteps*) getStepsForDifficulty:(TMSongDifficulty) difficulty {

	TMSteps* steps = nil;
	
	if(m_nFileType == kSongFileType_DWI) {
		steps = [DWIParser parseStepsFromFile:self.m_sFilePath 
				forDifficulty:difficulty forSong:self];	
	} else if(m_nFileType == kSongFileType_SM) {
		steps = [SMParser parseStepsFromFile:self.m_sFilePath 
				forDifficulty:difficulty forSong:self];	
	}

	return steps;
}

- (BOOL) isDifficultyAvailable:(TMSongDifficulty) difficulty {
	if(difficulty < kNumSongDifficulties && m_nAvailableDifficultyLevels[difficulty] != kSongDifficulty_Invalid) 
		return YES;
	return NO;
}

- (int)  getDifficultyLevel:(TMSongDifficulty) difficulty {
	if([self isDifficultyAvailable:difficulty])
		return m_nAvailableDifficultyLevels[difficulty];
	
	return -1;
}

- (void) enableDifficulty:(TMSongDifficulty) difficulty withLevel:(int) level {
	m_nAvailableDifficultyLevels[difficulty] = level;
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
