//
//  $Id$
//  AccelSoundPlayer.m
//  TapMania
//
//  Created by Alex Kremer on 14.08.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//
//  This class is based on GBMusicTrack code copyrighted by Jake Peterson (AnotherJake)
//  GBMusicTrack; Copyright 2008 Jake Peterson. All right reserved.
//

#import "AccelSoundPlayer.h"

static UInt32 gBufferSizeBytes = 131072;     // 128 KB buffers

@interface AccelSoundPlayer (Private)

static void BufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef buffer);

- (id)initDefaults:(NSString *)path;

- (void)callbackForBuffer:(AudioQueueBufferRef)buffer;

- (UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer;
@end

void PlayBackCallback(void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID);

@implementation AccelSoundPlayer

#pragma mark -
#pragma mark GBMusicTrack - AccelSoundPlayer
- (id)initDefaults:(NSString *)path
{
    UInt32 size;
    char *cookie;

    if (!(self = [super init]))
        return nil;
    if (path == nil)
        return nil;

    CFURLRef audioFileURL = CFURLCreateFromFileSystemRepresentation(NULL, (const UInt8 *) [path UTF8String], [path length], false);

    // try to open up the file using the specified path
    OSStatus res = AudioFileOpenURL(audioFileURL, kAudioFileReadPermission, kAudioFileCAFType, &audioFile);
    CFRelease(audioFileURL);

    if (res)
    {
        TMLog(@"AccelSoundPlayer Error [%d] - initWithPath: could not open audio file. Path given was: %@", res, path);
        return nil;
    }

    // get the data format of the file
    size = sizeof(dataFormat);
    AudioFileGetProperty(audioFile, kAudioFilePropertyDataFormat, &size, &dataFormat);

    // create a new playback queue using the specified data format and buffer callback
    AudioQueueNewOutput(&dataFormat, BufferCallback, self, nil, nil, 0, &queue);

    // Setup callback for play/finish notification
    AudioQueueAddPropertyListener(queue, kAudioQueueProperty_IsRunning, PlayBackCallback, self);

    // calculate number of packets to read and allocate space for packet descriptions if needed
    if (dataFormat.mBytesPerPacket == 0 || dataFormat.mFramesPerPacket == 0)
    {
        // since we didn't get sizes to work with, then this must be VBR data (Variable BitRate), so
        // we'll have to ask Core Audio to give us a conservative estimate of the largest packet we are
        // likely to read with kAudioFilePropertyPacketSizeUpperBound
        size = sizeof(maxPacketSize);
        AudioFileGetProperty(audioFile, kAudioFilePropertyPacketSizeUpperBound, &size, &maxPacketSize);
        if (maxPacketSize > gBufferSizeBytes)
        {
            // hmm... well, we don't want to go over our buffer size, so we'll have to limit it I guess
            maxPacketSize = gBufferSizeBytes;
            TMLog(@"AccelSoundPlayer Warning - initWithPath: had to limit packet size requested for file path: %@", path);
        }
        numPacketsToRead = gBufferSizeBytes / maxPacketSize;
        // will need a packet description for each packet since this is VBR data, so allocate space accordingly
        packetDescs = (AudioStreamPacketDescription *) malloc(sizeof(AudioStreamPacketDescription) * numPacketsToRead);
    }
    else
    {
        // for CBR data (Constant BitRate), we can simply fill each buffer with as many packets as will fit
        numPacketsToRead = gBufferSizeBytes / dataFormat.mBytesPerPacket;
        // don't need packet descriptsions for CBR data
        packetDescs = nil;
    }
    // see if file uses a magic cookie (a magic cookie is meta data which some formats use)
    AudioFileGetPropertyInfo(audioFile, kAudioFilePropertyMagicCookieData, &size, nil);
    if (size > 0)
    {
        // copy the cookie data from the file into the audio queue
        cookie = (char *) malloc(sizeof(char) * size);
        AudioFileGetProperty(audioFile, kAudioFilePropertyMagicCookieData, &size, cookie);
        AudioQueueSetProperty(queue, kAudioQueueProperty_MagicCookie, cookie, size);
        free(cookie);
    }

    m_bPaused = NO;
    m_bLoop = NO;
    m_fGain = 1.0f;    // Will probably be set by setGain
    startAtPacketIndex = stopAtPacketIndex = packetIndex = 0; // By default we will start playing at the begining

    return self;
}

- (id)initWithFile:(NSString *)inFile atPosition:(float)inTime withDuration:(float)inDuration looping:(BOOL)inLoop
{
    self = [self initDefaults:inFile];
    if (!self)
        return nil;

    m_bLoop = inLoop;

    if (inTime != 0)
    {

        // Need to translate from time to packet index
        if (dataFormat.mBytesPerPacket == 0 || dataFormat.mFramesPerPacket == 0)
        {
            UInt32 numBytes, numPackets;
            numPackets = numPacketsToRead;

            float seekToTime = inTime;
            void *dummyData = malloc(maxPacketSize * numPackets);

            BOOL doSeek = YES;
            float totalTime = 0;

            while (doSeek)
            {
                AudioFileReadPackets(audioFile, NO, &numBytes, packetDescs, packetIndex, &numPackets, dummyData);
                if (numPackets > 0)
                {
                    for (int i = 0; i < numPackets; ++i)
                    {
                        // Check this packet

                        if (packetDescs[i].mVariableFramesInPacket == 0)
                        {
                            totalTime += dataFormat.mFramesPerPacket / dataFormat.mSampleRate;
                        } else
                        {
                            totalTime += packetDescs[i].mVariableFramesInPacket / dataFormat.mSampleRate;
                        }

                        if (totalTime < seekToTime)
                        {
                            packetIndex += 1;
                        } else
                        {
                            doSeek = NO;
                            break;
                        }
                    }
                } else
                {
                    doSeek = NO;
                }
            }

            free(dummyData);

        } else
        {
            float packetTime = dataFormat.mFramesPerPacket / dataFormat.mSampleRate;
            packetIndex = inTime / packetTime;
        }

        // Save this position
        startAtPacketIndex = packetIndex;
    }

    // Now handle duration
    if (inDuration != 0.0f)
    {

        // Need to translate from time to packet index
        if (dataFormat.mBytesPerPacket == 0 || dataFormat.mFramesPerPacket == 0)
        {
            UInt32 numBytes, numPackets;
            numPackets = numPacketsToRead;

            float seekToTime = inTime + inDuration;
            void *dummyData = malloc(maxPacketSize * numPackets);

            BOOL doSeek = YES;
            float totalTime = 0;

            while (doSeek)
            {
                AudioFileReadPackets(audioFile, NO, &numBytes, packetDescs, stopAtPacketIndex, &numPackets, dummyData);
                if (numPackets > 0)
                {
                    for (int i = 0; i < numPackets; ++i)
                    {
                        // Check this packet

                        if (packetDescs[i].mVariableFramesInPacket == 0)
                        {
                            totalTime += dataFormat.mFramesPerPacket / dataFormat.mSampleRate;
                        } else
                        {
                            totalTime += packetDescs[i].mVariableFramesInPacket / dataFormat.mSampleRate;
                        }

                        if (totalTime < seekToTime)
                        {
                            stopAtPacketIndex += 1;
                        } else
                        {
                            doSeek = NO;
                            break;
                        }
                    }
                } else
                {
                    doSeek = NO;
                }
            }

            free(dummyData);

        } else
        {
            float packetTime = dataFormat.mFramesPerPacket / dataFormat.mSampleRate;
            stopAtPacketIndex = startAtPacketIndex + inDuration / packetTime;
        }
    }

    // TMLog(@"Start at packet: %d; stop at packet: %d; loop: %s", startAtPacketIndex, stopAtPacketIndex, m_bLoop?"YES":"NO");

    // Finally prime all the samples into our buffers
    [self primeBuffers];

    return self;
}

- (void)primeBuffers
{
    // allocate and prime buffers with some data
    UInt32 i;
    for (i = 0; i < NUM_QUEUE_BUFFERS; i++)
    {
        AudioQueueAllocateBuffer(queue, gBufferSizeBytes, &buffers[i]);
        if ([self readPacketsIntoBuffer:buffers[i]] == 0)
        {
            // this might happen if the file was so short that it needed less buffers than we planned on using
            break;
        }
    }

    // we would like to prime some frames so we are prepared to start directly
    UInt32 framesPrimed;
    AudioQueuePrime(queue, i, &framesPrimed);

    TMLog(@"Primed %d frames", framesPrimed);
}

- (void)dealloc
{
    AudioQueueDispose(queue, YES);
    [super dealloc];
}

- (BOOL)isPlaying
{
    UInt32 size, isRunning;

    AudioQueueGetPropertySize(queue, kAudioQueueProperty_IsRunning, &size);
    AudioQueueGetProperty(queue, kAudioQueueProperty_IsRunning, &isRunning, &size);

    return isRunning ? YES : NO;
}

- (BOOL)isPaused
{
    return m_bPaused;
}

- (void)stop
{
    if ([self isPlaying])
    {
        AudioQueueStop(queue, YES);
        AudioFileClose(audioFile);
    }
}

- (void)setGain:(Float32)gain
{
    AudioQueueSetParameter(queue, kAudioQueueParam_Volume, gain);
    m_fGain = gain;
}

- (Float32)getGain
{
    return m_fGain;
}

- (BOOL)play
{
    TMLog(@"Play issued. starting at %d", packetIndex);
    AudioQueueStart(queue, nil);
    /*
    if(!m_bLoop) {
        AudioQueueStop(queue, NO);	// Stop at end
    }*/

    m_bPaused = NO;
    return YES;
}

- (void)pause
{
    m_bPaused = YES;

    AudioQueuePause(queue);
}

#pragma mark -
#pragma mark Callback
static void BufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef buffer)
{
    // redirect back to the class to handle it there instead, so we have direct access to the instance variables
    [(AccelSoundPlayer *) inUserData callbackForBuffer:buffer];
}

void PlayBackCallback(void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID)
{
    if (![(AccelSoundPlayer *) inUserData isPlaying])
    {
        [(AccelSoundPlayer *) inUserData sendPlayBackFinishedNotification];
    } else
    {
        [(AccelSoundPlayer *) inUserData sendPlayBackStartedNotification];
    }
}

- (void)callbackForBuffer:(AudioQueueBufferRef)buffer
{
    if ([self readPacketsIntoBuffer:buffer] == 0)
    {
        // End Of File reached, so rewind and refill the buffer using the beginning of the file instead
        if (m_bLoop)
        {
            packetIndex = startAtPacketIndex;
            [self readPacketsIntoBuffer:buffer];
        }
    }
}

- (UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer
{
    UInt32 numBytes, numPackets;
    // read packets into buffer from file
    numPackets = numPacketsToRead;
    AudioFileReadPackets(audioFile, NO, &numBytes, packetDescs, packetIndex, &numPackets, buffer->mAudioData);
    if (numPackets > 0)
    {
        // - End Of File has not been reached yet since we read some packets, so enqueue the buffer we just read into
        // the audio queue, to be played next
        // - (packetDescs ? numPackets : 0) means that if there are packet descriptions (which are used only for Variable
        // BitRate data (VBR)) we'll have to send one for each packet, otherwise zero
        buffer->mAudioDataByteSize = numBytes;
        AudioQueueEnqueueBuffer(queue, buffer, (packetDescs ? numPackets : 0), packetDescs);
        // move ahead to be ready for next time we need to read from the file
        packetIndex += numPackets;

        if (stopAtPacketIndex != 0 && packetIndex >= stopAtPacketIndex)
        {
            if (m_bLoop)
                packetIndex = startAtPacketIndex;
            else
                return 0;
        }
    }
    return numPackets;
}

@end
