//
//  TMSong.h
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

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

@class TMSteps;
@class TMChangeSegment;

@interface TMSong : NSObject <NSCoding> {
	
	// Disk info
	NSString*		m_sFilePath;	// The path on the disk where the file used to get this song resides
	TMSongFileType	m_nFileType;	// The type of the file

	NSString*		m_sSongDirName;		// Path to this song's dir
 	NSString*		m_sHash;		// MD5 sum for this song
	
	// Music file info
	NSString*		m_sMusicFilePath;	// The path on the disk where the music file lives
	
	// Song information
	NSString* 	m_sTitle;
	NSString* 	m_sArtist;
	float	  	m_fBpm;
	double		m_dGap;
	
	int					m_nBpmChangeCount;
	int					m_nFreezeCount;
	int					m_nBpmCapacity;
	int					m_nFreezeCapacity;
	
	TMChangeSegment**	m_aBpmChangeArray;
	TMChangeSegment**	m_aFreezeArray;

	// Every difficulty which is available is set to the difficulty level (1+). set to -1 otherwise.
	int					m_nAvailableDifficultyLevels[kNumSongDifficulties];
}

@property (retain, nonatomic) NSString* m_sFilePath;
@property (assign) TMSongFileType m_nFileType;
@property (retain, nonatomic) NSString* m_sSongDirName;
@property (retain, nonatomic) NSString* m_sHash;

@property (retain, nonatomic) NSString* m_sMusicFilePath;

@property (retain, nonatomic) NSString* m_sArtist;
@property (retain, nonatomic, getter=title, setter=title:, readwrite) NSString* m_sTitle;
@property (assign) float m_fBpm;
@property (assign) double m_dGap;

@property (assign, readonly) int m_nFreezeCount;
@property (assign, readonly) int m_nBpmChangeCount;

@property (retain, nonatomic) TMChangeSegment** m_aBpmChangeArray;
@property (retain, nonatomic) TMChangeSegment** m_aFreezeArray;

// The constructor which is used. will parse the original stepmania file to determine song info.
- (id) initWithStepsFile:(NSString*) stepsFilePath andMusicFile:(NSString*) musicFilePath andDir:(NSString*) dir;

- (TMSteps*) getStepsForDifficulty:(TMSongDifficulty) difficulty;

- (BOOL) isDifficultyAvailable:(TMSongDifficulty) difficulty;
- (int)  getDifficultyLevel:(TMSongDifficulty) difficulty;
- (void) enableDifficulty:(TMSongDifficulty) difficulty withLevel:(int) level;

// Change arrays
- (void) addBpmSegment:(TMChangeSegment*)segment;
- (void) addFreezeSegment:(TMChangeSegment*)segment;

+ (NSString*) difficultyToString:(TMSongDifficulty)difficulty;

@end
