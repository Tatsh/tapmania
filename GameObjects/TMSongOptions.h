//
//  TMSongOptions.h
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMSong.h"

// Define available speed modifiers
typedef enum {
	kSpeedMod_1x = 0,
	kSpeedMod_1_5x,
	kSpeedMod_2x,
	kSpeedMod_3x,
	kSpeedMod_5x,
	kSpeedMod_8x,
	kSpeedMod_c200,
	kSpeedMod_c400,
	kSpeedMod_c600,
	kNumSpeedMods
} TMSpeedModifiers;


@interface TMSongOptions: NSObject {
	TMSpeedModifiers speedMod;
	TMSongDifficulty difficulty;
}

@property (readonly, assign) TMSpeedModifiers speedMod;
@property (readonly, assign) TMSongDifficulty difficulty;

// The constructor
- (id) init;

- (void) setSpeedMod:(TMSpeedModifiers)speed;
- (void) setDifficulty:(TMSongDifficulty)lDifficulty;

+ (NSString*) speedModAsString:(TMSpeedModifiers) speedMod;
+ (double) speedModToValue:(TMSpeedModifiers) speedMod;

@end
