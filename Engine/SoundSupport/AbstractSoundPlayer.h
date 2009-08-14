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
	BOOL		m_bPlaying;	// Control playback start
	BOOL		m_bPaused;	// YES if paused
}

// Methods. throw exceptions here
- (id) initWithFile:(NSString*)inFile;

- (void) play;		// Start playback
- (void) pause;		// Pause playback
- (void) stop;		// Stop the playback

- (BOOL) isPlaying;	// Check whether we are playing sound now
- (BOOL) isPaused;	// Check whether we are paused

- (BOOL) update;	// Update the buffers

@end
