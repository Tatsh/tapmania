//
//  TMSong.h
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

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
	kSongFileType_Invalid = 0,
	kSongFileType_DWI
} TMSongFileType;

#import "TMSteps.h"

@class TMSteps;

@interface TMSong : NSObject {
	
	// Disk info
	NSString*		filePath;	// The path on the disk where the file used to get this song resides
	TMSongFileType	fileType;	// The type of the file
	
	// Music file info
	NSString*		musicFilePath;	// The path on the disk where the music file lives
	
	// Song information
	NSString* 	title;
	NSString* 	artist;
	float	  	bpm;
	double		timePerBeat;		// Timing per beat (nanos)
	double		gap;
	
	NSMutableArray* bpmChangeArray;
	NSMutableArray* freezeArray;

	int _availableDifficultyLevels[kNumSongDifficulties];	// Every difficulty which is available is set to the difficulty level (1+). set to -1 otherwise.
}

@property (retain, nonatomic) NSString* filePath;
@property (assign) TMSongFileType fileType;

@property (retain, nonatomic) NSString* musicFilePath;

@property (retain, nonatomic) NSString* artist;
@property (retain, nonatomic) NSString* title;
@property (assign) float bpm;
@property (assign) double timePerBeat;
@property (assign) double gap;
@property (retain, nonatomic) NSMutableArray* bpmChangeArray;
@property (retain, nonatomic) NSMutableArray* freezeArray;

// The constructor which is used. will parse the original stepmania file to determine song info.
- (id) initWithStepsFile:(NSString*) lStepsFilePath andMusicFile:(NSString*) lMusicFilePath;

- (TMSteps*) getStepsForDifficulty:(TMSongDifficulty) difficulty;

- (BOOL) isDifficultyAvailable:(TMSongDifficulty) difficulty;
- (int)  getDifficultyLevel:(TMSongDifficulty) difficulty;
- (void) enableDifficulty:(TMSongDifficulty) difficulty withLevel:(int) level;

+ (NSString*) difficultyToString:(TMSongDifficulty)difficulty;

@end
