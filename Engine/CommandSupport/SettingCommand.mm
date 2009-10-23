//
//  SettingCommand.m
//  TapMania
//
//  Created by Alex Kremer on 23.10.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "SettingCommand.h"
#import "SettingsEngine.h"

@implementation SettingCommand

- (BOOL) invokeOnObject:(NSObject*)inObj {
	
	// Get the setting name to tune
	NSString* settingName = [m_aArguments objectAtIndex:0];
	if(!settingName || ![settingName length]) {
		return NO;
	}
	
	// Get new value to set
	NSObject* value = nil;
	NSString* tmp = [m_aArguments objectAtIndex:1];
	
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
		[[SettingsEngine sharedInstance] setValueFromObject:value forKey:settingName]; 
		return YES;
	}
		
	return NO;
}

@end
