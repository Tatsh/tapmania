//
//  TMSound.m
//  TapMania
//
//  Created by Alex Kremer on 19.08.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMSound.h"
#import "TMSoundEngine.h"

#import "AbstractSoundPlayer.h"
#import "OGGSoundPlayer.h"
#import "AccelSoundPlayer.h"

@implementation TMSound

@synthesize m_sPath, m_bAlreadyPlaying;

-(id) initWithPath:(NSString*)inPath {
	self = [super init];
	if (!self)
		return nil;
	
	m_sPath = inPath;
	m_bAlreadyPlaying = NO;
			
	return self;
}

/* TMSoundSupport delegate work */
- (void) playBackStartedNotification {
	m_bAlreadyPlaying = YES;
}

- (void) playBackFinishedNotification {
	m_bAlreadyPlaying = NO;
}

@end
