//
//  $Id$
//  OGGSoundPlayer.m
//  TapMania
//
//  Created by Alex Kremer on 24.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

/* 
 * This code is pretty much based on the great OGG streaming article by Jesse Maurais (http://www.devmaster.net/articles/openal-tutorials/lesson8.php )
 */

#import "OGGSoundPlayer.h"
#import <OpenAL/al.h>
#import <OpenAL/alc.h>

#define BUFFER_SIZE        131072     // 128 KB buffers

@interface OGGSoundPlayer (Private)
- (BOOL)stream:(ALuint)buffer;        // Stream
- (void)empty;                        // Clear the queue
- (void)playback;

- (NSString *)errStr:(int)code;

- (void)checkErr;

- (void)worker;                    // Thread worker
@end


@implementation OGGSoundPlayer

- (id)initWithFile:(NSString *)inFile atPosition:(float)inTime withDuration:(float)inDuration looping:(BOOL)inLoop
{
    self = [super init];
    if (!self)
        return nil;

    TMLog(@"Try to init ogg player for file '%@'", inFile);

    m_pFile = fopen([inFile UTF8String], "rb");
    if (!m_pFile)
    {
        TMLog(@"ERROR opening OGG file from %@", inFile);
        return nil;
    }

    // Open the stream
    if (ov_open(m_pFile, &m_oStream, NULL, 0) < 0)
    {
        fclose(m_pFile);

        [self checkErr];
    }

    // Get infos
    m_pVorbisInfo = ov_info(&m_oStream, -1);
    [self checkErr];

    if (m_pVorbisInfo->channels == 1)
        m_nFormat = AL_FORMAT_MONO16;
    else
        m_nFormat = AL_FORMAT_STEREO16;

    m_nFreq = m_pVorbisInfo->rate;

    // Generate buffers and source
    alGenBuffers(kSoundEngineNumBuffers, m_nBuffers);
    [self checkErr];

    alGenSources(1, &m_nSourceID);
    [self checkErr];

    alSource3f(m_nSourceID, AL_POSITION, 0.0, 0.0, 0.0);
    alSource3f(m_nSourceID, AL_VELOCITY, 0.0, 0.0, 0.0);
    alSource3f(m_nSourceID, AL_DIRECTION, 0.0, 0.0, 0.0);

    alSourcef(m_nSourceID, AL_PITCH, 1.0f);
    alSourcef(m_nSourceID, AL_GAIN, 1.0f);

    alSourcei(m_nSourceID, AL_LOOPING, AL_FALSE);
    alSourcef(m_nSourceID, AL_ROLLOFF_FACTOR, 0.0);
    alSourcei(m_nSourceID, AL_SOURCE_RELATIVE, AL_TRUE);

    // Construct thread
    m_pThread = [[NSThread alloc] initWithTarget:self selector:@selector(worker) object:nil];

    TMLog(@"Done constructing OGG player!");

    // Start thread. the thread will start streaming in background till play is invoked
    m_bPlaying = NO;
    m_bPaused = NO;
    m_bLoop = NO;

    [m_pThread start];

    return self;
}

- (void)dealloc
{
    [self stop];

    // Cleanup
    alDeleteSources(1, &m_nSourceID);
    alDeleteBuffers(kSoundEngineNumBuffers, m_nBuffers);

    [m_pThread release];
    ov_clear(&m_oStream);

    [super dealloc];
}

- (void)worker
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Thread entrance point
    TMLog(@"START PLAYBACK THREAD!");

    while ([self update])
    {
        if (m_bPlaying)
        {
            if (![self isPlaying])
            {
                alSourcePlay(m_nSourceID);
            }
        }
    }

    [pool drain];
}

/* Highlevel methods */
- (BOOL)play
{
    m_bPlaying = YES;
    m_bPaused = NO;

    [self playback];
    return YES;
}

- (void)pause
{
    m_bPaused = YES;
    m_bPlaying = NO;

    alSourcePause(m_nSourceID);
}

- (BOOL)isPlaying
{
    ALenum state;
    alGetSourcei(m_nSourceID, AL_SOURCE_STATE, &state);
    [self checkErr];

    return (state == AL_PLAYING);
}

- (BOOL)isPaused
{
    ALenum state;
    alGetSourcei(m_nSourceID, AL_SOURCE_STATE, &state);
    [self checkErr];

    return (state == AL_PAUSED);
}

- (void)stop
{
    if ([self isPlaying])
    {
        alSourceStop(m_nSourceID);
        [self checkErr];
    }

    // Unqueue the rest
    [self empty];
}

- (void)playback
{
    if ([self isPlaying])
    {
        return;
    }

    // Fill with first chunks
    int bufId = 0;
    for (; bufId < kSoundEngineNumBuffers; ++bufId)
    {
        if (![self stream:m_nBuffers[bufId]])
            return;
    }

    alSourceQueueBuffers(m_nSourceID, kSoundEngineNumBuffers, m_nBuffers);
    [self checkErr];

    alSourcePlay(m_nSourceID);
    [self checkErr];
}

// Return YES if still active. NO on end of stream
- (BOOL)update
{
    int processed;
    BOOL active = YES;

    alGetSourcei(m_nSourceID, AL_BUFFERS_PROCESSED, &processed);
    [self checkErr];

    TMLog(@"We have %d processed buffers...", processed);

    while (processed--)
    {
        ALuint buffer;

        alSourceUnqueueBuffers(m_nSourceID, 1, &buffer);
        [self checkErr];

        active = [self stream:buffer];

        alSourceQueueBuffers(m_nSourceID, 1, &buffer);
        [self checkErr];
    }

    return active;
}

/* Lowlevel methods */
// Return YES if stream is ok. NO if end reached or got error
- (BOOL)stream:(ALuint)buffer
{
    char data[BUFFER_SIZE];
    int size = 0;
    int section;
    int result;

    TMLog(@"Stream to buffer %d", buffer);

    while (size < BUFFER_SIZE)
    {
        result = ov_read(&m_oStream, data + size, BUFFER_SIZE - size, 0, 2, 1, &section);
        [self checkErr];

        TMLog(@"Got %d bytes data...", result);

        if (result > 0)
        {
            size += result;
            TMLog(@"Cur size: %d", size);
        } else
        {
            if (result < 0)
            {
                TMLog(@"ERROR in OGG");
                return NO;
            }
            else
            {
                break;
                // We are done...
            }
        }
    }

    // Finished?
    if (size == 0)
        return NO;

    TMLog(@"DONE. Store buffer with size: %d", size);
    alBufferData(buffer, m_nFormat, data, size, m_nFreq);
    [self checkErr];

    return YES;
}

- (void)empty
{
    int queued;

    alGetSourcei(m_nSourceID, AL_BUFFERS_QUEUED, &queued);
    [self checkErr];

    while (queued--)
    {
        ALuint buffer;

        alSourceUnqueueBuffers(m_nSourceID, 1, &buffer);
        [self checkErr];
    }
}

- (NSString *)errStr:(int)code
{
    switch (code)
    {
        case OV_EREAD:
            return @"Read from media";
        case OV_ENOTVORBIS:
            return @"Not vorbis data";
        case OV_EVERSION:
            return @"Invalid vorbis version";
        case OV_EBADHEADER:
            return @"Invalid vorbis header";
        case OV_EFAULT:
            return @"Internal logic fault";
        default:
            return @"Unknown OGG error";
    }
}

- (void)checkErr
{
    int err = alGetError();

    if (err != AL_NO_ERROR)
    {
        NSException *ex = [NSException exceptionWithName:@"OpenALError" reason:[self errStr:err] userInfo:nil];
        @throw ex;
    }

}

@end
