//
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

@class AbstractSoundPlayer;

@interface TMSoundEngine : NSObject <TMSoundSupport> {
	ALCcontext  *m_oContext;
	ALCdevice	*m_oDevice;

	BOOL		m_bEffectsEnabled;	// Disable/Enable sound effects (not music)
	
	float		m_fMusicVolume;		// Music sound volume
	float		m_fEffectsVolume;	// Effects sound volume
	
	NSTimer	    *m_pFadeTimer;		// Fade support
	float		m_fMusicFadeStart;
	float		m_fMusicFadeDuration;
	
	// Current bg music player
	AbstractSoundPlayer*	m_pCurrentMusicPlayer;
	
	id			m_idDelegate;
}

@property (assign, setter=delegate:, getter=delegate) id<TMSoundSupport> m_idDelegate;

-(void) shutdownOpenAL;

// Methods
- (BOOL) loadMusicFile:(NSString*) inPath;	// File format is determined automatically and the corresponding playr is used
- (void) unloadMusic;						// Just unload it (free memory)

// Music playback
- (BOOL) playMusic;
- (BOOL) pauseMusic;
- (BOOL) stopMusic;
- (BOOL) stopMusicFading:(float)duration;			// Fade out music and stop it when done
- (BOOL) setMusicPosition:(float) inPosition;		// Set the current position in the music file

- (void) setMasterVolume:(float)gain;
- (float) getMasterVolume;

- (void) setLoop:(BOOL)loop;

// TODO sound effects stuff

+ (TMSoundEngine *)sharedInstance;

@end
