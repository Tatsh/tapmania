//
//  TMSongOptions.h
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
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
