//
//  TMSong.h
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	kSongFileType_Invalid = 0,
	kSongFileType_DWI
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

@interface TMSong : NSObject {
	
	// Disk info
	NSString*		m_sFilePath;	// The path on the disk where the file used to get this song resides
	TMSongFileType	m_nFileType;	// The type of the file
	
	// Music file info
	NSString*		m_sMusicFilePath;	// The path on the disk where the music file lives
	
	// Song information
	NSString* 	m_sTitle;
	NSString* 	m_sArtist;
	float	  	m_fBpm;
	double		m_dGap;
	
	NSMutableArray* m_aBpmChangeArray;
	NSMutableArray* m_aFreezeArray;

	int m_nAvailableDifficultyLevels[kNumSongDifficulties];	// Every difficulty which is available is set to the difficulty level (1+). set to -1 otherwise.
}

@property (retain, nonatomic) NSString* m_sFilePath;
@property (assign) TMSongFileType m_nFileType;

@property (retain, nonatomic) NSString* m_sMusicFilePath;

@property (retain, nonatomic) NSString* m_sArtist;
@property (retain, nonatomic) NSString* m_sTitle;
@property (assign) float m_fBpm;
@property (assign) double m_dGap;
@property (retain, nonatomic) NSMutableArray* m_aBpmChangeArray;
@property (retain, nonatomic) NSMutableArray* m_aFreezeArray;

// The constructor which is used. will parse the original stepmania file to determine song info.
- (id) initWithStepsFile:(NSString*) stepsFilePath andMusicFile:(NSString*) musicFilePath;

- (TMSteps*) getStepsForDifficulty:(TMSongDifficulty) difficulty;

- (BOOL) isDifficultyAvailable:(TMSongDifficulty) difficulty;
- (int)  getDifficultyLevel:(TMSongDifficulty) difficulty;
- (void) enableDifficulty:(TMSongDifficulty) difficulty withLevel:(int) level;

+ (NSString*) difficultyToString:(TMSongDifficulty)difficulty;

@end
