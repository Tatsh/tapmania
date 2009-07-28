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

#import "SongsDirectoryCache.h"

@implementation TMSong

@synthesize m_nFileType, m_sFilePath, m_sMusicFilePath, m_sSongDirName;
@synthesize m_sHash;
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

- (id) initWithStepsFile:(NSString*) stepsFilePath andMusicFile:(NSString*) musicFilePath andDir:(NSString*) dir {
	
	// Note: only title etc is loaded here. No steps.
	if([[stepsFilePath lowercaseString] hasSuffix:@".dwi"]) {
		self = [DWIParser parseFromFile:[[[SongsDirectoryCache sharedInstance] getSongsPath] stringByAppendingPathComponent:stepsFilePath]];
		self.m_nFileType = kSongFileType_DWI;
		
	} else if([[stepsFilePath lowercaseString] hasSuffix:@".sm"]) {
		self = [SMParser parseFromFile:[[[SongsDirectoryCache sharedInstance] getSongsPath] stringByAppendingPathComponent:stepsFilePath]];	
		self.m_nFileType = kSongFileType_SM;
		
	} else {
		TMLog(@"Some unknown format...");
		return nil;
	}
	
	self.m_sMusicFilePath = musicFilePath;
	self.m_sFilePath = stepsFilePath;
	self.m_sSongDirName  = dir;
	
	TMLog(@"Set musicpath: '%@' and steps: '%@'", m_sMusicFilePath, m_sFilePath);
	
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
		steps = [DWIParser parseStepsFromFile:[[[SongsDirectoryCache sharedInstance] getSongsPath] stringByAppendingPathComponent:self.m_sFilePath]
				forDifficulty:difficulty forSong:self];	
	} else if(m_nFileType == kSongFileType_SM) {
		steps = [SMParser parseStepsFromFile:[[[SongsDirectoryCache sharedInstance] getSongsPath] stringByAppendingPathComponent:self.m_sFilePath]
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

// Serialization
- (id) initWithCoder: (NSCoder *) coder {
	self.m_sSongDirName = [[coder decodeObjectForKey:@"sdn"] retain];
	self.m_sFilePath = [[coder decodeObjectForKey:@"fp"] retain];
	self.m_sMusicFilePath = [[coder decodeObjectForKey:@"mp"] retain];
	self.m_sHash = [[coder decodeObjectForKey:@"ha"] retain];
	self.m_nFileType = [coder decodeIntForKey:@"ft"];
	
	self.m_sTitle = [[coder decodeObjectForKey:@"t"] retain];
	self.m_sArtist = [[coder decodeObjectForKey:@"a"] retain];

	self.m_fBpm = [coder decodeFloatForKey:@"b"];
	self.m_dGap = [coder decodeDoubleForKey:@"g"];

	m_nBpmChangeCount = [coder decodeIntForKey:@"bc"];
	m_nFreezeCount = [coder decodeIntForKey:@"fc"];
	
	NSArray* bpmChangeArr = [coder decodeObjectForKey:@"bca"];
	NSArray* freezeArr = [coder decodeObjectForKey:@"fca"];
	
	int i = 0;
	m_nBpmCapacity = self.m_nBpmChangeCount;
	m_aBpmChangeArray = (TMChangeSegment**)realloc(m_aBpmChangeArray, m_nBpmCapacity*sizeof(TMChangeSegment*));	
	
	for (TMChangeSegment* segment in bpmChangeArr) {
		m_aBpmChangeArray[i++] = [segment retain];
	}
	
	i = 0;
	m_nFreezeCapacity = self.m_nFreezeCount;
	m_aFreezeArray = (TMChangeSegment**)realloc(m_aFreezeArray, m_nFreezeCapacity*sizeof(TMChangeSegment*));	
	
	for (TMChangeSegment* segment in freezeArr) {
		m_aFreezeArray[i++] = [segment retain];
	}
	
	NSMutableArray* availDiff = [coder decodeObjectForKey:@"adl"];
	i = 0;
	for (NSNumber* val in availDiff) {
		m_nAvailableDifficultyLevels[i++] = [val intValue];
	}
	
	return self;
}

- (void) encodeWithCoder: (NSCoder *) coder {
	[coder encodeObject:m_sSongDirName forKey:@"sdn"];
	[coder encodeObject:m_sFilePath forKey:@"fp"];
	[coder encodeObject:m_sMusicFilePath forKey:@"mp"];	
	[coder encodeObject:m_sHash forKey:@"ha"];
	[coder encodeInt:m_nFileType forKey:@"ft"];
	
	[coder encodeObject:m_sTitle forKey:@"t"];
	[coder encodeObject:m_sArtist forKey:@"a"];
	
	[coder encodeFloat:m_fBpm forKey:@"b"];
	[coder encodeDouble:m_dGap forKey:@"g"];

	[coder encodeInt:m_nBpmChangeCount forKey:@"bc"];
	[coder encodeInt:m_nFreezeCount forKey:@"fc"];
	
	[coder encodeObject:[NSArray arrayWithObjects:m_aBpmChangeArray count:m_nBpmChangeCount] forKey:@"bca"];
	[coder encodeObject:[NSArray arrayWithObjects:m_aFreezeArray count:m_nFreezeCount] forKey:@"fca"];
	
	NSMutableArray* diffArr = [NSMutableArray arrayWithCapacity:kNumSongDifficulties+1];

	int i;
	for (i=0; i<kNumSongDifficulties; ++i) {
		[diffArr addObject:[NSNumber numberWithInt:(m_nAvailableDifficultyLevels[i])]];
	}	
	
	[coder encodeObject:diffArr forKey:@"adl"];
}

@end
