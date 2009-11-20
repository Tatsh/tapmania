//
//  $Id$
//  TMSong.h
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#ifdef __cplusplus
#import "ObjCPtr.h"
#include <vector>
#endif

#define kDefaultChangesCapacity 16

typedef enum {
	kSongFileType_Invalid = 0,
	kSongFileType_DWI,
	kSongFileType_SM
} TMSongFileType;

typedef enum {
	kSongDifficulty_Invalid = 0,
	kSongDifficulty_Beginner,
	kSongDifficulty_Easy,
	kSongDifficulty_Medium,
	kSongDifficulty_Hard,
	kSongDifficulty_Challenge,
	kNumSongDifficulties
} TMSongDifficulty;

typedef enum {
	kFailOn = 0,
	kFailOff,
	kFailAtEnd,
	kNumFailTypes
} TMFailType;

@class TMSteps;
@class TMChangeSegment;

#ifdef __cplusplus
typedef ObjCPtr<TMChangeSegment>			TMChangeSegmentPtr;
typedef std::vector<TMChangeSegmentPtr>		TMChangeSegmentVec;
#endif

@interface TMSong : NSObject <NSCoding> {
	
	// Disk info
	NSString*		m_sFilePath;	// The path on the disk where the file used to get this song resides
	TMSongFileType	m_nFileType;	// The type of the file

	NSString*		m_sSongDirName;		// Path to this song's dir
 	NSString*		m_sHash;		// MD5 sum for this song
	
	// Music file info
	NSString*		m_sMusicFilePath;	// The path on the disk where the music file lives
	float			m_fPreviewStart;	// Preview music in song selection screen
	float			m_fPreviewDuration;
	
	// Song information
	NSString* 	m_sTitle;
	NSString* 	m_sArtist;
	float	  	m_fBpm;
	double		m_dGap;
		
	#ifdef __cplusplus
	TMChangeSegmentVec	m_aBpmChangeArray;
	TMChangeSegmentVec	m_aFreezeArray;
	#endif

	// Every difficulty which is available is set to the difficulty level (1+). set to -1 otherwise.
	int					m_nAvailableDifficultyLevels[kNumSongDifficulties];
}

@property (retain, nonatomic) NSString* m_sFilePath;
@property (assign) TMSongFileType m_nFileType;
@property (retain, nonatomic) NSString* m_sSongDirName;
@property (retain, nonatomic) NSString* m_sHash;

@property (retain, nonatomic) NSString* m_sMusicFilePath;
@property (assign) float m_fPreviewStart;
@property (assign) float m_fPreviewDuration;


@property (retain, nonatomic) NSString* m_sArtist;
@property (retain, nonatomic, getter=title, setter=title:, readwrite) NSString* m_sTitle;
@property (assign) float m_fBpm;
@property (assign) double m_dGap;

// The constructor which is used. will parse the original stepmania file to determine song info.
- (id) initWithStepsFile:(NSString*) stepsFilePath andMusicFile:(NSString*) musicFilePath andDir:(NSString*) dir;

- (TMSteps*) getStepsForDifficulty:(TMSongDifficulty) difficulty;

- (BOOL) isDifficultyAvailable:(TMSongDifficulty) difficulty;
- (int)  getDifficultyLevel:(TMSongDifficulty) difficulty;
- (void) enableDifficulty:(TMSongDifficulty) difficulty withLevel:(int) level;

// Change arrays
- (void) addBpmSegment:(TMChangeSegment*)segment;
- (void) addFreezeSegment:(TMChangeSegment*)segment;

- (TMChangeSegment*) getBpmChangeAt:(int)inIndex;
- (int) getBpmChangeCount;

- (TMChangeSegment*) getFreezeAt:(int)inIndex;
- (int) getFreezeCount;

+ (NSString*) difficultyToString:(TMSongDifficulty)difficulty;

@end
