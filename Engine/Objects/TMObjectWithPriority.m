//
//  TMObjectWithPriority.m
//  TapMania
//
//  Created by Alex Kremer on 26.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMObjectWithPriority.h"

@implementation TMObjectWithPriority

@synthesize m_pObj, m_uPriority;

-(id) initWithObj:(NSObject*)obj andPriority:(unsigned)priority {
	self = [super init];
	if(!self)
		return nil;
	
	m_pObj = obj;
	m_uPriority = priority;	
	
	return self;
}

@end
