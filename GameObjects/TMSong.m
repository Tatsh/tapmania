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
@synthesize m_nBpmChangeCount, m_nFreezeCount;

- (id) init {
	self = [super init];
	if(!self)
		return nil;

	m_nBpmCapacity = kDefaultChangesCapacity;
	m_aBpmChangeArray = (TMChangeSegment**)malloc(sizeof(TMChangeSegment*)*m_nBpmCapacity);
	m_nBpmChangeCount = 0;

	m_nFreezeCapacity = kDefaultChangesCapacity;
	m_aFreezeArray = (TMChangeSegment**)malloc(sizeof(TMChangeSegment*)*m_nFreezeCapacity);
	m_nFreezeCount = 0;
	
	return self;
}

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
	
	self.m_sMusicFilePath = musicFilePath;
	self.m_sFilePath = stepsFilePath;
	
	return self;
}

- (void) dealloc {
	free(m_aBpmChangeArray);
	free(m_aFreezeArray);
	
	[super dealloc];
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

- (void) addBpmSegment:(TMChangeSegment*)segment {
	// realloc buffer
	if(m_nBpmChangeCount >= m_nBpmCapacity) {
		m_nBpmCapacity += kDefaultChangesCapacity;
		m_aBpmChangeArray = (TMChangeSegment**)realloc(m_aBpmChangeArray, m_nBpmCapacity*sizeof(TMChangeSegment*));	
	}
	
	m_aBpmChangeArray[m_nBpmChangeCount++] = segment;	
}

- (void) addFreezeSegment:(TMChangeSegment*)segment {
	// realloc buffer
	if(m_nFreezeCount >= m_nFreezeCapacity) {
		m_nFreezeCapacity += kDefaultChangesCapacity;
		m_aFreezeArray = (TMChangeSegment**)realloc(m_aFreezeArray, m_nFreezeCapacity*sizeof(TMChangeSegment*));	
	}
	
	m_aFreezeArray[m_nFreezeCount++] = segment;	
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
