//
//  $Id$
//  AbstractSoundPlayer.m
//  TapMania
//
//  Created by Alex Kremer on 24.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "AbstractSoundPlayer.h"
#import "TMSoundEngine.h"

@implementation AbstractSoundPlayer

@synthesize m_idDelegate;
@synthesize markedAsStopped = _markedAsStopped;


- (id)initWithFile:(NSString *)inFile atPosition:(float)inTime withDuration:(float)inDuration looping:(BOOL)inLoop
{
    NSException *ex = [NSException exceptionWithName:@"AbstractClass" reason:@"This class should not be used directly" userInfo:nil];
    @throw ex;

    return nil;
}

- (void)primeBuffers
{
};

- (BOOL)play
{
    return NO;
}

- (void)pause
{
}

- (BOOL)isPlaying
{
    return NO;
}

- (BOOL)isPaused
{
    return NO;
}

- (void)stop
{
}

- (BOOL)update
{
    return NO;
}

- (void)setGain:(Float32)gain
{
}

- (Float32)getGain
{
    return 1.0f;
};

- (void)setLoop:(BOOL)loop
{
    m_bLoop = loop;
}

- (BOOL)isLooping
{
    return m_bLoop;
}

- (void)sendPlayBackStartedNotification
{
    if (m_idDelegate && [m_idDelegate respondsToSelector:@selector(playBackStartedNotification)])
    {
        [m_idDelegate performSelectorOnMainThread:@selector(playBackStartedNotification) withObject:nil waitUntilDone:NO];
    }

    // Also notify the sound engine
    [[TMSoundEngine sharedInstance] performSelectorOnMainThread:@selector(playBackStartedNotification) withObject:nil waitUntilDone:NO];
}

- (void)sendPlayBackFinishedNotification
{
    if (m_idDelegate && [m_idDelegate respondsToSelector:@selector(playBackFinishedNotification)])
    {
        [m_idDelegate performSelectorOnMainThread:@selector(playBackFinishedNotification) withObject:nil waitUntilDone:NO];
    }

    // Also notify the sound engine
    [[TMSoundEngine sharedInstance] performSelectorOnMainThread:@selector(playBackFinishedNotification) withObject:nil waitUntilDone:NO];
}

@end
