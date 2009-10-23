//
//  TMCommand.mm
//  TapMania
//
//  Created by Alex Kremer on 9/20/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMCommand.h"
#import "TapMania.h"
#import "SettingsEngine.h"

@implementation TMCommand

- (id) initWithArguments:(NSArray*) inArgs andInvocationObject:(NSObject*) inObj {
	self = [super init];
	if(!self)
		return nil;
	
	m_aArguments = [inArgs copy];
	m_pInvocationObject = inObj;
	
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

- (void) setInvocationObject:(NSObject*)inObj {
	m_pInvocationObject = inObj;
}

/* TMLogicUpdater stuff */
- (void) update:(float)fDelta {
	// The simplest case is actually invoke the command and finish in one iteration
	[self invokeOnObject:m_pInvocationObject];
	[[TapMania sharedInstance] deregisterObject:self];
}

/* TMRenderable stuff */
- (void) render:(float)fDelta {
}

- (id)copyWithZone:(NSZone *)zone {
	return [[[self class] alloc] initWithArguments:m_aArguments andInvocationObject:m_pInvocationObject];
}


@end
