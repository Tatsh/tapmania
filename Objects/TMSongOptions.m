//
//  TMSongOptions.m
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMSongOptions.h"


@implementation TMSongOptions


- (id) initWithSpeed:(TMSpeedModifiers)lSpeedMod {
	self = [super init];
	if(!self)
		return nil;
	
	if(lSpeedMod != -1 && lSpeedMod < kNumSpeedMods){
		speedMod = lSpeedMod;
	} else {
		speedMod = kSpeedMod_1x;
	}
	
	return self;
}

- (TMSpeedModifiers) getSpeedMod {
	return speedMod;
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
		case kSpeedMod_c200:
			return @"C200";
		case kSpeedMod_c400:
			return @"C400";
		case kSpeedMod_c600:
			return @"C600";	
		default:
			return @"UNKNOWN";
	}
}

@end
