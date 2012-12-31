//
//  $Id$
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
#import "TMFramedTexture.h"

@implementation TMSong

@synthesize m_nFileType, m_sFilePath, m_sMusicFilePath, m_sSongDirName;
@synthesize m_sBackgroundFilePath, m_sBannerFilePath;
@synthesize m_fPreviewStart, m_fPreviewDuration;
@synthesize m_sHash, m_iSongsPath;
@synthesize m_sTitle, m_sArtist;
@synthesize m_fBpm, m_dGap;
@synthesize bannerTexture = _bannerTexture;
@synthesize m_sCDTitleFilePath = _m_sCDTitleFilePath;
@synthesize cdTitleTexture = _cdTitleTexture;


- (id) initWithStepsFile:(NSString*)stepsFilePath andMusicFile:(NSString*)musicFilePath andBackgroundFile:(NSString*)backgroundFilePath andDir:(NSString*)dir fromSongsPathId:(TMSongsPath)pathId {
	
	self.m_iSongsPath = pathId;
    self.cdTitleTexture = nil;
    self.bannerTexture = nil;
    self.m_sCDTitleFilePath = nil;
	
	// Note: only title etc is loaded here. No steps.
	if([[stepsFilePath lowercaseString] hasSuffix:@".dwi"]) {
		self = [DWIParser parseFromFile:[[[SongsDirectoryCache sharedInstance] getSongsPath:self.m_iSongsPath] stringByAppendingPathComponent:stepsFilePath]];
		self.m_nFileType = kSongFileType_DWI;
		
	} else if([[stepsFilePath lowercaseString] hasSuffix:@".sm"]) {
		self = [SMParser parseFromFile:[[[SongsDirectoryCache sharedInstance] getSongsPath:self.m_iSongsPath] stringByAppendingPathComponent:stepsFilePath]];	
		self.m_nFileType = kSongFileType_SM;
		
	} else {
		TMLog(@"Some unknown format...");
		return nil;
	}
	
	self.m_sMusicFilePath = musicFilePath;
	self.m_sFilePath = stepsFilePath;
	self.m_sSongDirName = dir;
	self.m_sBackgroundFilePath = backgroundFilePath;
	
	TMLog(@"Set musicpath:'%@' and steps: '%@' and background: '%@'", m_sMusicFilePath, m_sFilePath, m_sBackgroundFilePath);
	
	return self;
}

- (TMSteps*) getStepsForDifficulty:(TMSongDifficulty) difficulty {

	TMSteps* steps = nil;
	
	if(m_nFileType == kSongFileType_DWI) {
		steps = [DWIParser parseStepsFromFile:[[[SongsDirectoryCache sharedInstance] getSongsPath:self.m_iSongsPath] stringByAppendingPathComponent:self.m_sFilePath]
				forDifficulty:difficulty forSong:self];	
	} else if(m_nFileType == kSongFileType_SM) {
		steps = [SMParser parseStepsFromFile:[[[SongsDirectoryCache sharedInstance] getSongsPath:self.m_iSongsPath] stringByAppendingPathComponent:self.m_sFilePath]
				forDifficulty:difficulty forSong:self];	
	}

	[steps setDifficultyLevel:[self getDifficultyLevel:difficulty]];
	
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
	m_aBpmChangeArray.push_back( TMChangeSegmentPtr(segment) );
}

- (void) addFreezeSegment:(TMChangeSegment*)segment {
	m_aFreezeArray.push_back( TMChangeSegmentPtr(segment) );
}

- (TMChangeSegment*) getBpmChangeAt:(int)inIndex {
	if(inIndex >= m_aBpmChangeArray.size()) return nil;
	return m_aBpmChangeArray.at(inIndex).get();
}

- (int) getBpmChangeCount {
	return m_aBpmChangeArray.size();
}

- (TMChangeSegment*) getFreezeAt:(int)inIndex {
	if(inIndex >= m_aFreezeArray.size()) return nil;
	return m_aFreezeArray.at(inIndex).get();
}

- (int) getFreezeCount {
	return m_aFreezeArray.size();
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
	self.m_fPreviewStart = [coder decodeFloatForKey:@"ps"];
	self.m_fPreviewDuration = [coder decodeFloatForKey:@"pd"];
	self.m_sHash = [[coder decodeObjectForKey:@"ha"] retain];
	self.m_iSongsPath = (TMSongsPath)[coder decodeIntForKey:@"sp"];
	self.m_nFileType = (TMSongFileType)[coder decodeIntForKey:@"ft"];
	
	self.m_sTitle = [[coder decodeObjectForKey:@"t"] retain];
	self.m_sArtist = [[coder decodeObjectForKey:@"a"] retain];
	self.m_sBackgroundFilePath = [[coder decodeObjectForKey:@"bfp"] retain];
	self.m_sBannerFilePath = [[coder decodeObjectForKey:@"bafp"] retain];
    self.m_sCDTitleFilePath = [[coder decodeObjectForKey:@"cdfp"] retain];;
	
	self.m_fBpm = [coder decodeFloatForKey:@"b"];
	self.m_dGap = [coder decodeDoubleForKey:@"g"];
	
	NSArray* bpmChangeArr = [coder decodeObjectForKey:@"bca"];
	NSArray* freezeArr = [coder decodeObjectForKey:@"fca"];
	
	for (TMChangeSegment* segment in bpmChangeArr) {
		m_aBpmChangeArray.push_back([segment retain]);
	}
		
	for (TMChangeSegment* segment in freezeArr) {
		m_aFreezeArray.push_back([segment retain]);
	}
	
	NSMutableArray* availDiff = [coder decodeObjectForKey:@"adl"];
	int i = 0;
	for (NSNumber* val in availDiff) {
		m_nAvailableDifficultyLevels[i++] = [val intValue];
	}
	
	return self;
}

- (void) encodeWithCoder: (NSCoder *) coder {
	[coder encodeObject:m_sSongDirName forKey:@"sdn"];
	[coder encodeObject:m_sFilePath forKey:@"fp"];
	[coder encodeObject:m_sMusicFilePath forKey:@"mp"];	
	[coder encodeFloat:m_fPreviewStart forKey:@"ps"];
	[coder encodeFloat:m_fPreviewDuration forKey:@"pd"];
	[coder encodeObject:m_sHash forKey:@"ha"];
	[coder encodeInt:m_iSongsPath forKey:@"sp"];
	[coder encodeInt:m_nFileType forKey:@"ft"];
	
	[coder encodeObject:m_sTitle forKey:@"t"];
	[coder encodeObject:m_sArtist forKey:@"a"];
	[coder encodeObject:m_sBackgroundFilePath forKey:@"bfp"];
	[coder encodeObject:m_sBannerFilePath forKey:@"bafp"];
    [coder encodeObject:_m_sCDTitleFilePath forKey:@"cdfp"];
	
	[coder encodeFloat:
            m_fBpm forKey:@"b"];
	[coder encodeDouble:m_dGap forKey:@"g"];
	
	NSMutableArray* bpmArr = [NSMutableArray arrayWithCapacity:m_aBpmChangeArray.size()];
	NSMutableArray* freezeArr = [NSMutableArray arrayWithCapacity:m_aFreezeArray.size()];
	
	TMChangeSegmentVec::iterator it;
	for(it=m_aBpmChangeArray.begin(); it!=m_aBpmChangeArray.end(); it++) {
		[bpmArr addObject:it->get()];
	}

	for(it=m_aFreezeArray.begin(); it!=m_aFreezeArray.end(); it++) {
		[freezeArr addObject:it->get()];
	}
	
	[coder encodeObject:bpmArr forKey:@"bca"];
	[coder encodeObject:freezeArr forKey:@"fca"];
	
	NSMutableArray* diffArr = [NSMutableArray arrayWithCapacity:kNumSongDifficulties+1];

	for (int i=0; i<kNumSongDifficulties; ++i) {
		[diffArr addObject:[NSNumber numberWithInt:(m_nAvailableDifficultyLevels[i])]];
	}	
	
	[coder encodeObject:diffArr forKey:@"adl"];
}

- (void)dealloc
{
    [_m_sCDTitleFilePath release];
    [_cdTitleTexture release];
    [super dealloc];
}

@end




@implementation TMSongSavedScore 

@synthesize hash, difficulty, bestScore, bestGrade;

+(NSArray *)indices
{
	NSArray* index = [NSArray arrayWithObjects:@"hash", @"difficulty", nil];
	return [NSArray arrayWithObjects:index, nil];
}

@end


