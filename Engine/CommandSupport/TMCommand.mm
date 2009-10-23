//
//  TMCommand.mm
//  TapMania
//
//  Created by Alex Kremer on 9/20/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMCommand.h"
#import "SettingsEngine.h"

@implementation TMCommand

- (id) initWithArguments:(NSArray*) inArgs {
	self = [super init];
	if(!self)
		return nil;
	
	m_aArguments = [inArgs copy];
	
	return self;
}

- (void) dealloc {
	[m_aArguments release];
	[super dealloc];
}

- (BOOL) invokeAtConstructionOnObject:(NSObject*)inObj {
	return NO;
}

- (BOOL) invokeOnObject:(NSObject*)inObj {
	return NO;
}


- (NSObject*) getValueFromString:(NSString*)str withObject:(NSObject*)inObj {
	
	if([str hasPrefix:@"{setting:"]) {
		NSString* tmp = [str stringByReplacingOccurrencesOfString:@"{setting:" withString:@""];
		tmp = [tmp stringByReplacingOccurrencesOfString:@"}" withString:@""];
		
		return [[SettingsEngine sharedInstance] getObjectValue:tmp];
	}
	else if([str isEqualToString:@"{value}"]) {
		if([inObj respondsToSelector:@selector(currentValue)]) {
			return [inObj performSelector:@selector(currentValue)];
		} else {
			TMLog(@"CurrentValue method not supported by this object: %@", inObj);
			return nil;
		}
	}
	else {
		return str;
	}
}


@end
