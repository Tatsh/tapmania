//
//  AbstractSoundPlayer.m
//  TapMania
//
//  Created by Alex Kremer on 24.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "AbstractSoundPlayer.h"
#import "TMSoundEngine.h"

@implementation AbstractSoundPlayer

- (id) initWithFile:(NSString*)inFile {
	NSException *ex = [NSException exceptionWithName:@"AbstractClass" reason:@"This class should not be used directly" userInfo:nil];
	@throw ex;

	return nil;
}

- (void) play {}
- (void) pause {}
- (BOOL) isPlaying { return NO; }
- (BOOL) isPaused { return NO; }
- (void) stop {}
- (BOOL) update { return NO; }
- (void) setGain:(Float32)gain {}
- (Float32) getGain { return 1.0f; };

- (void) setLoop:(BOOL)loop { m_bLoop = loop; }
- (BOOL) isLooping { return m_bLoop; }

- (void) sendPlayBackFinishedNotification {
	[[TMSoundEngine sharedInstance] performSelectorOnMainThread:@selector(playBackFinishedNotification) withObject:nil waitUntilDone:YES];
}

@end
