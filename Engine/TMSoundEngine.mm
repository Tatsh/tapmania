//
//  $Id$
//  TMSoundEngine.m
//  TapMania
//
//  Created by Alex Kremer on 18.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMSoundEngine.h"

#import "TMSound.h"
#import "TMLoopedSound.h"

#import "AbstractSoundPlayer.h"
#import "OGGSoundPlayer.h"
#import "AccelSoundPlayer.h"

#import "TimingUtil.h"

#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioFile.h>
#import <AVFoundation/AVFoundation.h>

#import <vorbis/vorbisfile.h>

@interface TMSoundEngine (Private)
- (BOOL)initOpenAL;

- (void)musicFadeOutTick:(NSTimer *)sender;

- (void)worker;
@end

// This is a singleton class, seebelow
static TMSoundEngine *sharedSoundEngineDelegate = nil;

/* We will need some C routines to use OpenAL. this routines are coded by Apple */
typedef ALvoid AL_APIENTRY (*alBufferDataStaticProcPtr)(const ALint bid, ALenum format, ALvoid *data, ALsizei size, ALsizei freq);

ALvoid alBufferDataStaticProc(const ALint bid, ALenum format, ALvoid *data, ALsizei size, ALsizei freq)
{
    static alBufferDataStaticProcPtr proc = NULL;

    if (proc == NULL)
    {
        proc = (alBufferDataStaticProcPtr) alcGetProcAddress(NULL, (const ALCchar *) "alBufferDataStatic");
    }

    if (proc)
        proc(bid, format, data, size, freq);

    return;
}


void *getOpenALAudioData(CFURLRef inFileURL, ALsizei *outDataSize, ALenum *outDataFormat, ALsizei *outSampleRate)
{
    OSStatus err = noErr;
    SInt64 theFileLengthInBytes = 0;
    AudioStreamBasicDescription theFileFormat;
    UInt32 thePropertySize = sizeof(theFileFormat);
    AudioFileID aFID;
    UInt32 dataSize = 0;

    void *theData = NULL;
    AudioStreamBasicDescription theOutputFormat;

    // Open a file
    err = AudioFileOpenURL(inFileURL, kAudioFileReadPermission, 0, &aFID);
    if (err)
    {
        printf("getOpenALAudioData: AudioFileOpenURL FAILED, Error = %ld\n", err);
        goto Exit;
    }

    // Get the audio data format
    err = AudioFileGetProperty(aFID, kAudioFilePropertyDataFormat, &thePropertySize, &theFileFormat);
    if (err)
    {
        printf("getOpenALAudioData: AudioFileGetProperty(kAudioFilePropertyDataFormat) FAILED, Error = %ld\n", err);
        goto Exit;
    }
    if (theFileFormat.mChannelsPerFrame > 2)
    {
        printf("getOpenALAudioData - Unsupported Format, channel count is greater than stereo\n");
        goto Exit;
    }

    // Set the client format to 16 bit signed integer (native-endian) data
    // Maintain the channel count and sample rate of the original source format
    theOutputFormat.mSampleRate = theFileFormat.mSampleRate;
    theOutputFormat.mChannelsPerFrame = theFileFormat.mChannelsPerFrame;

    theOutputFormat.mFormatID = kAudioFormatLinearPCM;
    theOutputFormat.mBytesPerPacket = 2 * theOutputFormat.mChannelsPerFrame;
    theOutputFormat.mFramesPerPacket = 1;
    theOutputFormat.mBytesPerFrame = 2 * theOutputFormat.mChannelsPerFrame;
    theOutputFormat.mBitsPerChannel = 16;
    theOutputFormat.mFormatFlags = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;

    // Get the total frame count
    thePropertySize = sizeof(theFileLengthInBytes);
    err = AudioFileGetProperty(aFID, kAudioFilePropertyAudioDataByteCount, &thePropertySize, &theFileLengthInBytes);
    if (err)
    {
        printf("getOpenALAudioData: AudioFileGetProperty(kAudioFilePropertyAudioDataByteCount) FAILED, Error = %ld\n", err);
        goto Exit;
    }

    // Read all the data into memory
    dataSize = theFileLengthInBytes;
    theData = malloc(dataSize);
    if (theData)
    {
        AudioBufferList theDataBuffer;
        theDataBuffer.mNumberBuffers = 1;
        theDataBuffer.mBuffers[0].mDataByteSize = dataSize;
        theDataBuffer.mBuffers[0].mNumberChannels = theOutputFormat.mChannelsPerFrame;
        theDataBuffer.mBuffers[0].mData = theData;

        // Read the data into an AudioBufferList
        err = AudioFileReadBytes(aFID, true, 0, (UInt32 *) &theFileLengthInBytes, &theDataBuffer);

        if (err == noErr)
        {
            // success
            *outDataSize = (ALsizei) dataSize;
            *outDataFormat = (theOutputFormat.mChannelsPerFrame > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
            *outSampleRate = (ALsizei) theOutputFormat.mSampleRate;
        }
        else
        {
            // failure
            free(theData);
            theData = NULL; // make sure to return NULL
            printf("getOpenALAudioData: AudioFileRead FAILED, Error = %ld\n", err);
            goto Exit;
        }
    }

    Exit:
            // Close the AudioFileRef, it is no longer needed
            if (aFID)
                AudioFileClose(aFID);

    return theData;
}

/* Now to the implementation */
@implementation TMSoundEngine

- (id)init
{
    self = [super init];
    if (!self)
        return nil;

    m_fMusicVolume = 1.0f;
    m_fEffectsVolume = 1.0f;
    m_bManualStart = NO;

    m_pQueue = new TMSoundQueue();

    m_pThread = [[NSThread alloc] initWithTarget:self selector:@selector(worker) object:nil];

    return self;
}

- (NSThread *)getThread
{
    return m_pThread;
}

- (void)start
{
    m_bStopRequested = NO;
    [m_pThread start];
}

- (void)stop
{
    m_bStopRequested = YES;
}

- (void)worker
{
    if (![self initOpenAL])
        return;

    while (!m_bStopRequested)
    {

        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

        @synchronized (self)
        {
            if (!m_bPlayingSomething && !m_bManualStart)
            {
                if (!m_pQueue->empty())
                {
                    [self playMusic];
                }
            }
        }

        [pool drain];

        // Give some CPU time to others
        [NSThread sleepForTimeInterval:0.05];
    }
}

- (void)dealloc
{
    alcDestroyContext(m_oContext);
    alcCloseDevice(m_oDevice);

    if (m_pFadeTimer)
    {
        [m_pFadeTimer invalidate];
        [m_pFadeTimer release];
    }

    delete m_pQueue;
    [super dealloc];
}

- (BOOL)initOpenAL
{

    TMLog(@"Try to init openal...");
    m_oDevice = alcOpenDevice(NULL);

    if (m_oDevice)
    {
        TMLog(@"Got a device!");
        m_oContext = alcCreateContext(m_oDevice, NULL);
        alcMakeContextCurrent(m_oContext);

        TMLog(@"Great! context is made current! we are in...");

        return YES;
    }

    return NO;
}

- (void)shutdownOpenAL
{
    @synchronized (self)
    {
        if (sharedSoundEngineDelegate != nil)
        {
            [self dealloc];
        }
    }
}


// Methods
- (BOOL)addToQueue:(TMSound *)inObj
{

    // Get a sound player for the track
    AbstractSoundPlayer *pSoundPlayer = nil;

    // Check looping
    BOOL isLooping = NO;
    if ([inObj isKindOfClass:[TMLoopedSound class]])
        isLooping = YES;

    if ([[inObj.path lowercaseString] hasSuffix:@".ogg"])
    {
        pSoundPlayer = [[OGGSoundPlayer alloc] initWithFile:inObj.path atPosition:inObj.position withDuration:inObj.duration looping:isLooping];
    } else
    {
        pSoundPlayer = [[AccelSoundPlayer alloc] initWithFile:inObj.path atPosition:inObj.position withDuration:inObj.duration looping:isLooping];
    }

    if (!pSoundPlayer)
        return NO;

    // Set delegate
    [pSoundPlayer delegate:inObj];

    @synchronized (self)
    {
        m_pQueue->push_back(pair<TMSound *, AbstractSoundPlayer *>([inObj retain], pSoundPlayer));
    }

    return YES;
}

- (BOOL)addToQueueWithManualStart:(TMSound *)inObj
{
    m_bManualStart = YES;
    [self addToQueue:inObj];
    return YES;
}

- (BOOL)removeFromQueue:(TMSound *)inObj
{
    TMSoundQueue::iterator it;

    @synchronized (self)
    {
        if (!m_pQueue->empty())
        {
            for (it = m_pQueue->begin(); it != m_pQueue->end(); ++it)
            {
                if (it->first == inObj)
                {

                    [it->second release];
                    [it->first release];

                    m_pQueue->erase(it);

                    return YES;
                }
            }
        }
    }

    return NO;
}

// Music playback
- (BOOL)playMusic
{
    @synchronized (self)
    {
        TMLog(@"Play music issued!");

        if (!m_pQueue->empty())
        {
            AbstractSoundPlayer *pPlayer = m_pQueue->front().second;
            TMLog(@"Got player: %X", pPlayer);
            [pPlayer setGain:m_fMusicVolume];
            if ([pPlayer play])
                m_bPlayingSomething = YES;
        }
    }

    m_bManualStart = NO;    // Drop the flag
    return m_bPlayingSomething;
}

- (BOOL)pauseMusic
{
    @synchronized (self)
    {
        if (!m_pQueue->empty())
        {
            AbstractSoundPlayer *pPlayer = m_pQueue->front().second;
            [pPlayer pause];
            return YES;
        }
    }

    return NO;
}

- (BOOL)stopMusicFading:(float)duration
{
    @synchronized (self)
    {
        TMLog(@"Stopping current track with fade out (%f)!", duration);

        if (!m_pQueue->empty())
        {
            if (m_pFadeTimer)
            {
                [m_pFadeTimer invalidate];
                [m_pFadeTimer release];
            }

            AbstractSoundPlayer *pPlayer = m_pQueue->front().second;
            m_pFadeTimer = [[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(musicFadeOutTick:) userInfo:pPlayer repeats:YES] retain];
            m_fMusicFadeStart = [TimingUtil getCurrentTime];
            m_fMusicFadeDuration = duration;

            return YES;
        }
    }

    return NO;
}

- (void)musicFadeOutTick:(NSTimer *)sender
{
    @synchronized (self)
    {
        float elapsedTime = ([TimingUtil getCurrentTime] - m_fMusicFadeStart);
        float gain = 1 - (elapsedTime / m_fMusicFadeDuration);    // Inverse

        AbstractSoundPlayer *pPlayer = (AbstractSoundPlayer *) [sender userInfo];

        // If the player still exists
        if (pPlayer)
        {
            TMLog(@"player still exists...");

            if (gain <= 0.01f)
            {
                TMLog(@"Time to stop the fading music track: %X", pPlayer);

                // Stop fading
                [m_pFadeTimer invalidate];

                // Stop music too
                [self stopMusic];
            } else if (pPlayer && [pPlayer getGain] >= gain)
            {
                [pPlayer setGain:gain];
            }
        }
    }
}

- (BOOL)stopMusic
{
    AbstractSoundPlayer *pPlayer = nil;

    @synchronized (self)
    {
        TMLog(@"Actually stopping the current track!");

        if (!m_pQueue->empty())
        {
            pPlayer = m_pQueue->front().second;
            TMLog(@"Got player to stop: %X", pPlayer);
        }
    }

    if (pPlayer)
    {
        [pPlayer stop];
        TMLog(@"Player stopped");

        // PlayingSomething flag will be set using a callback notification
        return YES;
    }

    return NO;
}

- (void)setMasterVolume:(float)gain
{
    m_fMusicVolume = gain;

    @synchronized (self)
    {
        if (!m_pQueue->empty())
        {
            AbstractSoundPlayer *pPlayer = m_pQueue->front().second;
            [pPlayer setGain:gain];
        }
    }
}

- (float)getMasterVolume
{
    return m_fMusicVolume;
}

- (void)setEffectsVolume:(float)gain
{
    m_fEffectsVolume = gain;
}

- (float)getEffectsVolume
{
    return m_fEffectsVolume;
}


/* TMSoundSupport delegate work */
- (void)playBackStartedNotification
{
    TMLog(@"SOUNDENGINE: got notification about current track playback Started");
    m_bPlayingSomething = YES;
}

- (void)playBackFinishedNotification
{
    @synchronized (self)
    {
        TMLog(@"SOUNDENGINE: got notification about current track Stopped");

        AbstractSoundPlayer *pPlayer = m_pQueue->front().second;
        TMLog(@"Got player to stop: %X", pPlayer);

        [pPlayer release];
        TMLog(@"Player released");

        m_pQueue->pop_front();
        TMLog(@"Popped player out of queue.");

        m_bPlayingSomething = NO;
    }
}

// Effect support (short sounds)
- (BOOL)playEffect:(TMSound *)inSound
{
    NSError *err;
    AVAudioPlayer *avSound = [[AVAudioPlayer alloc] initWithContentsOfURL:
            [NSURL fileURLWithPath:inSound.path]                    error:&err];

    if (!avSound)
    {
        TMLog(@"PlayEffect err: %@", [err localizedDescription]);
        return NO;
    }

    // Set gain
    [avSound setVolume:m_fEffectsVolume];

    return [avSound play];
}

#pragma mark Singleton stuff
+ (TMSoundEngine *)sharedInstance
{
    @synchronized (self)
    {
        if (sharedSoundEngineDelegate == nil)
        {
            [[self alloc] init];
        }
    }
    return sharedSoundEngineDelegate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized (self)
    {
        if (sharedSoundEngineDelegate == nil)
        {
            sharedSoundEngineDelegate = [super allocWithZone:zone];
            return sharedSoundEngineDelegate;
        }
    }

    return nil;
}


- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release
{
    // NOTHING
}

- (id)autorelease
{
    return self;
}

@end
