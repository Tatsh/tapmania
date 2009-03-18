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

@interface TMSoundEngine : NSObject {
	BOOL		m_bEffectsEnabled;	// Disable/Enable sound effects (not music)
	
	float		m_fMusicVolume;		// Music sound volume
	float		m_fEffectsVolume;	// Effects sound volume
}

// Methods
- (BOOL) loadMusicFile:(NSString*) inPath;	// Files are loaded completely into the memory
- (void) unloadMusic;						// Just unload it (free memory)

// Music playback
- (BOOL) playMusic;
- (BOOL) pauseMusic;
- (BOOL) stopMusic;
- (BOOL) setMusicPosition:(float) inPosition;		// Set the current position in the music file

- (void) fadeOutMusic:(float) inTimeDelta;			// inTimeDelta specfies the time from start of fade out till silence.

// TODO sound effects stuff

+ (TMSoundEngine *)sharedInstance;

@end
