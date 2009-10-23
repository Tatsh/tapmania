//
//  SoundCommand.m
//  TapMania
//
//  Created by Alex Kremer on 23.10.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "SoundCommand.h"
#import "TMSoundEngine.h"

@implementation SoundCommand

- (BOOL) invokeOnObject:(NSObject*)inObj {
	
	// Get new value to set
	NSString* tmp = [m_aArguments objectAtIndex:0];
	NSObject* value = nil;
	
	if([tmp isEqualTo:@"{value}"]) {
		if([inObj respondsToSelector:@selector(currentValue)]) {
			value = [inObj performSelector:@selector(currentValue)];
			TMLog(@"Got current value: %@", value);
		}
	} else {
		if([tmp length]) {
			// TODO: add int/float etc. conversions
			value = tmp;
			TMLog(@"Setting value: %@", value);
		}
	}	
	
	if(value) {
		[[TMSoundEngine sharedInstance] setMasterVolume:[(NSNumber*)value floatValue]];
		return YES;
	}
	
	return NO;
}

@end
