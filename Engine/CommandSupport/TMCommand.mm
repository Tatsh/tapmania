//
//  TMCommand.mm
//  TapMania
//
//  Created by Alex Kremer on 9/20/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMCommand.h"

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

@end
