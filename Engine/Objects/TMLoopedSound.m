//
//  TMLoopedSound.m
//  TapMania
//
//  Created by Alex Kremer on 19.08.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMLoopedSound.h"
#import "TMSoundEngine.h"

@implementation TMLoopedSound

-(void) play {
	if(!m_bIsPlaying) {
		TMLog(@"Play file: %@", m_sPath);
		[[TMSoundEngine sharedInstance] loadMusicFile:m_sPath];
		[[TMSoundEngine sharedInstance] delegate:self];
		[[TMSoundEngine sharedInstance] setLoop:YES];
		[[TMSoundEngine sharedInstance] playMusic];
		m_bIsPlaying = YES;
	}
}

@end
