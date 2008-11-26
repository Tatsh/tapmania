//
//  TMObjectWithPriority.m
//  TapMania
//
//  Created by Alex Kremer on 26.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMObjectWithPriority.h"

@implementation TMObjectWithPriority

@synthesize obj, priority;

-(id) initWithObj:(NSObject*)lObj andPriority:(unsigned)lPriority {
	self = [super init];
	if(!self)
		return nil;
	
	obj = lObj;
	priority = lPriority;	
	
	return self;
}

@end
