//
//  TMSongOptions.h
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

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
}

@property (readonly, assign) TMSpeedModifiers speedMod;

// The constructor
- (id) initWithSpeed:(TMSpeedModifiers)speedMod;

+ (NSString*) speedModAsString:(TMSpeedModifiers) speedMod;

@end
