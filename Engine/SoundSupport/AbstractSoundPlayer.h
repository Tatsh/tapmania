//
//  $Id$
//  AbstractSoundPlayer.h
//  TapMania
//
//  Created by Alex Kremer on 24.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import <OpenAL/alc.h>
#import <OpenAL/al.h>
#import "TMSoundSupport.h"

#define kSoundEngineNumBuffers    2

@interface AbstractSoundPlayer : NSObject
{
    BOOL m_bPlaying;    // Control playback start
    BOOL m_bPaused;    // YES if paused
    BOOL m_bLoop;    // YES if should loop

    id m_idDelegate;
}

@property(assign, setter=delegate:, getter=delegate) id <TMSoundSupport> m_idDelegate;

@property(nonatomic) BOOL markedAsStopped;

// Methods. throw exceptions here
- (id)initWithFile:(NSString *)inFile atPosition:(float)inTime withDuration:(float)inDuration looping:(BOOL)inLoop;

- (void)primeBuffers;

- (BOOL)play;        // Start playback
- (void)pause;        // Pause playback
- (void)stop;        // Stop the playback

- (BOOL)isPlaying;    // Check whether we are playing sound now
- (BOOL)isPaused;    // Check whether we are paused

- (BOOL)update;    // Update the buffers

- (void)setGain:(Float32)gain;

- (Float32)getGain;

- (void)setLoop:(BOOL)loop;

- (BOOL)isLooping;

- (void)sendPlayBackStartedNotification;

- (void)sendPlayBackFinishedNotification;

@end
