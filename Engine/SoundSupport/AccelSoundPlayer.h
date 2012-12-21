//
//  $Id$
//  AccelSoundPlayer.h
//  TapMania
//
//  Created by Alex Kremer on 14.08.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//
//  This class is based on GBMusicTrack code copyrighted by Jake Peterson (AnotherJake)
//  GBMusicTrack; Copyright 2008 Jake Peterson. All right reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>

#define NUM_QUEUE_BUFFERS    3

#import "AbstractSoundPlayer.h"

/*
	This is the sound player which can play anything what can be played using the iphone hardware
 */
@interface AccelSoundPlayer : AbstractSoundPlayer
{
    AudioFileID audioFile;
    AudioStreamBasicDescription dataFormat;
    AudioQueueRef queue;

    UInt64 packetIndex;
    UInt64 startAtPacketIndex;
    UInt64 stopAtPacketIndex;

    UInt32 numPacketsToRead, maxPacketSize;
    AudioStreamPacketDescription *packetDescs;
    AudioQueueBufferRef buffers[NUM_QUEUE_BUFFERS];

    float m_fGain;
}

@end
