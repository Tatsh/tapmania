//
//  AbstractSoundPlayer.m
//  TapMania
//
//  Created by Alex Kremer on 24.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "AbstractSoundPlayer.h"

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
- (void)setGain:(Float32)gain {}

@end
