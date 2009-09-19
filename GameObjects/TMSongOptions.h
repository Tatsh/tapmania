//
//  TMSongOptions.h
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMSong.h"	// For TMSongDifficulty

// Define available speed modifiers
typedef enum {
	kSpeedMod_1x = 0,
	kSpeedMod_1_5x,
	kSpeedMod_2x,
	kSpeedMod_3x,
	kSpeedMod_5x,
	kSpeedMod_8x,
	kNumSpeedMods
} TMSpeedModifiers;

typedef enum {
	kFailOn = 0,	// Default. fail when lifebar drained
	kFailOff,		// No fail. always clear a song
	kFailAtEnd,		// Fail at end if lifebar was drained
	kNumFailTypes
} TMFailType;

@interface TMSongOptions: NSObject {
	TMSpeedModifiers m_nSpeedMod;
	TMSongDifficulty m_nDifficulty;
}

@property (readonly, assign) TMSpeedModifiers m_nSpeedMod;
@property (readonly, assign) TMSongDifficulty m_nDifficulty;

// The constructor
- (id) init;

- (void) setSpeedMod:(TMSpeedModifiers)speed;
- (void) setDifficulty:(TMSongDifficulty)lDifficulty;

+ (NSString*) speedModAsString:(TMSpeedModifiers) speedMod;
+ (double) speedModToValue:(TMSpeedModifiers) speedMod;

@end
