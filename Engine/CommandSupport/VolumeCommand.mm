//
//  VolumeCommand.mm
//  TapMania
//
//  Created by Alex Kremer on 23.10.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "VolumeCommand.h"
#import "TMSoundEngine.h"

@implementation VolumeCommand

- (id) initWithArguments:(NSArray*) inArgs {
	self = [super initWithArguments:inArgs];
	if(!self)
		return nil;
	
	if([inArgs count] != 1) {
		TMLog(@"Wrong argument count for command 'volume'. abort.");
		return nil;
	}
	
	return self;
}

- (BOOL) invokeOnObject:(NSObject*)inObj {
	
	// Get new value to set
	NSObject* value = [self getValueFromString:[m_aArguments objectAtIndex:0] withObject:inObj];
	
	if(value) {
		[[TMSoundEngine sharedInstance] setMasterVolume:[(NSNumber*)value floatValue]];
		return YES;
	}
	
	return NO;
}

@end
