//
//  AbstractSoundPlayer.h
//  TapMania
//
//  Created by Alex Kremer on 24.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import <OpenAL/alc.h>
#import <OpenAL/al.h>

#define kSoundEngineNumBuffers	2

@interface AbstractSoundPlayer : NSObject {
	FILE*  m_pFile;	// The file handle
	
	ALuint	m_nBuffers[kSoundEngineNumBuffers];	// We have back and front buffers
	ALuint	m_nSourceID;	
	ALenum	m_nFormat;		
	ALsizei m_nFreq;
	
	// Threading
	NSThread*	m_pThread;
	BOOL		m_bPlaying;	// Control playback start
}

// Methods. throw exceptions here
- (id) initWithFile:(NSString*)inFile;

- (void) play;		// Start playback
- (BOOL) isPlaying;	// Check whether we are playing sound now
- (void) stop;		// Stop the playback
- (BOOL) update;	// Update the buffers


@end
