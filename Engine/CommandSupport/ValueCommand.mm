//
//  ValueCommand.m
//  TapMania
//
//  Created by Alex Kremer on 23.10.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "ValueCommand.h"
#import "SettingsEngine.h"

@implementation ValueCommand

- (BOOL) invokeAtConstructionOnObject:(NSObject*)inObj {
	if([inObj respondsToSelector:@selector(setValue:)]) {
		
		NSString* tmp = [m_aArguments objectAtIndex:0];
		NSObject* value = nil;
		
		if([tmp hasPrefix:@"{setting:"]) {
			tmp = [tmp stringByReplacingOccurrencesOfString:@"{setting:" withString:@""];
			tmp = [tmp stringByReplacingOccurrencesOfString:@"}" withString:@""];
			
			value = [[SettingsEngine sharedInstance] getObjectValue:tmp];
		} else {
			value = tmp;
		}
		
		if(value) {
			[inObj performSelector:@selector(setValue:) withObject:value];
			return YES;
		}
	}
	
	return NO;
}

@end
