//
//  $Id$
//  TMSoundEngine.h
//  TapMania
//
//  Created by Alex Kremer on 18.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

/* 
 This is my alternative to SoundEngine by Apple. 
 The code is inspired by the great OpenAL tutorial by hhamm (http://gehacktes.net/2009/03/iphone-programming-part-6-multiple-sounds-with-openal)
 Apple's SoundEngine was great but it didn't support .ogg and changing the code there was a pain for me.
 
 This sound engine should support both .mp3 and .ogg. (Unfortunatly it seems like .ogg is out of support by Apple atm. have to wait a bit)
*/

#import <OpenAL/alc.h>
#import "TMSoundSupport.h"

@class TMSound, AbstractSoundPlayer;

#ifdef __cplusplus

#include <list>

using namespace std;

typedef list<pair<TMSound *, AbstractSoundPlayer *> > TMSoundQueue;
#endif

@interface TMSoundEngine : NSObject <TMSoundSupport>
{

#ifdef __cplusplus
    TMSoundQueue *m_pQueue;        // Queue of music resources
#endif
    NSThread *m_pThread;            // Dedicated thread for sound

    ALCcontext *m_oContext;
    ALCdevice *m_oDevice;

    BOOL m_bEffectsEnabled;    // Disable/Enable sound effects (not music)

    float m_fMusicVolume;        // Music sound volume
    float m_fEffectsVolume;    // Effects sound volume

    NSTimer *m_pFadeTimer;        // Fade support
    float m_fMusicFadeStart;
    float m_fMusicFadeDuration;

@private
    BOOL m_bStopRequested;
    BOOL m_bPlayingSomething;
    BOOL m_bManualStart;        // If set to true the soundengine will wait for us to invoke play manually
}

- (NSThread *)getThread;

- (void)shutdownOpenAL;

// Methods
- (void)start;                                // Start the sound engine thread
- (void)stop;                                // Stop the sound thread
- (BOOL)addToQueue:(TMSound *)inObj;        // Adds a TMSound object to the queue
- (BOOL)addToQueueWithManualStart:(TMSound *)inObj;

- (BOOL)removeFromQueue:(TMSound *)inObj;    // Removes the TMSound object from the queue if it was enqueued before

// Music playback control
- (BOOL)playMusic;                            // Starts playing the first element of the queue or continue if paused
- (BOOL)pauseMusic;                        // Pauses the queue
- (BOOL)stopMusic;                            // Stops the currently playing music (removes the track from the queue)

// Fade in/out support
- (BOOL)stopMusicFading:(float)duration;        // Fade out music and stop it when done (removes the track from the queue)

// Volume control
- (void)setMasterVolume:(float)gain;

- (float)getMasterVolume;

- (void)setEffectsVolume:(float)gain;

- (float)getEffectsVolume;


// Effects stuff
- (BOOL)playEffect:(TMSound *)inSound;

+ (TMSoundEngine *)sharedInstance;

@end
