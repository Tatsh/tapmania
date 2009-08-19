//
//  TMSound.m
//  TapMania
//
//  Created by Alex Kremer on 19.08.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMSound.h"
#import "TMSoundEngine.h"

@implementation TMSound

-(id) initWithPath:(NSString*)inPath {
	self = [super init];
	if (!self)
		return nil;
	
	m_sPath = inPath;
	m_bIsPlaying = NO;
	
	return self;
}

-(void) play {
	if(!m_bIsPlaying) {
		TMLog(@"Play file: %@", m_sPath);
		[[TMSoundEngine sharedInstance] loadMusicFile:m_sPath];
		[[TMSoundEngine sharedInstance] delegate:self];
		[[TMSoundEngine sharedInstance] playMusic];
		m_bIsPlaying = YES;
	}
}

/* TMSoundSupport delegate work */
- (void) playBackFinishedNotification {
	TMLog(@"Queue is finished!!!");
}

-(void) dealloc {
	[m_sPath release];
	[super dealloc];
}

@end
