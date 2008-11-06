//
//  TMSteps.m
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMSteps.h"


@implementation TMSteps

- (id) initWithFile:(NSString*) filename {
	self = [super init];
	if(!self) 
		return nil;
	
	// TODO impl
	
	return self;
}

- (int) getDifficultyLevel {
	return difficultyLevel;
}

- (TMSongDifficulty) getDifficulty {
	return difficulty;
}

@end
