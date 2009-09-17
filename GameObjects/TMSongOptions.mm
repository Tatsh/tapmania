//
//  TMSongOptions.m
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMSongOptions.h"


@implementation TMSongOptions

@synthesize m_nSpeedMod, m_nDifficulty;

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	m_nSpeedMod = kSpeedMod_1x;
	m_nDifficulty = kSongDifficulty_Invalid;

	return self;
}

- (void) setSpeedMod:(TMSpeedModifiers)speed {
	m_nSpeedMod = speed;
}

- (void) setDifficulty:(TMSongDifficulty)lDifficulty {
	m_nDifficulty = lDifficulty;
}

// Get string representation of the speed modifier
+ (NSString*) speedModAsString:(TMSpeedModifiers) speedMod {
	switch (speedMod) {
		case kSpeedMod_1x:
			return @"1x";
		case kSpeedMod_1_5x:
			return @"1.5x";
		case kSpeedMod_2x:
			return @"2x";
		case kSpeedMod_3x:
			return @"3x";
		case kSpeedMod_5x:
			return @"5x";
		case kSpeedMod_8x:
			return @"8x";
		default:
			return @"UNKNOWN";
	}
}

+ (double) speedModToValue:(TMSpeedModifiers) speedMod {
	switch (speedMod) {
		case kSpeedMod_1x:
			return 1.0f;
		case kSpeedMod_1_5x:
			return 1.5f;
		case kSpeedMod_2x:
			return 2.0f;
		case kSpeedMod_3x:
			return 3.0f;
		case kSpeedMod_5x:
			return 5.0f;
		case kSpeedMod_8x:
			return 8.0f;
		default:
			return 1.0f;
	}
}

@end
