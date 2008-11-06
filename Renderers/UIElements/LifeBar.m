//
//  LifeBar.m
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "LifeBar.h"


@implementation LifeBar

- (id) init {
	self = [super init];
	if(!self) 
		return nil;
	
	_currentValue = 50.0f;
	
	return self;
}

- (float) getCurrentValue {
	return _currentValue;
}

- (void) updateBy:(float)value {
	_currentValue += value;
}

@end
