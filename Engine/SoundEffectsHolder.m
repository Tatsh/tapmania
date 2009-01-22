//
//  SoundEffectsHolder.m
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "SoundEffectsHolder.h"
#import "SoundEngine.h"

// This is a singleton class, see below
static SoundEffectsHolder *sharedSoundEffectsDelegate = nil;

@implementation SoundEffectsHolder

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	//Setup sound engine. Run it at 44Khz to match the sound files
	SoundEngine_Initialize(44100);	
	
	NSLog(@"Loading sound effects...");
	
	// FIXME: hardcode
	NSString* themeDir = @"default";
	
	SoundEngine_SetListenerPosition(0.0, 0.0, 1.0);
	SoundEngine_SetEffectsVolume(1.0);
	SoundEngine_SetBackgroundMusicVolume(1.0);
	
	SoundEngine_LoadEffect([[NSString stringWithFormat:@"themes/%@/Sounds/%@", themeDir, @"tick.wav"] UTF8String], &_sounds[kSound_Clap]);
	
	NSLog(@"Done.");
	
	return self;
}

- (void) dealloc {
	SoundEngine_Teardown();	
	
	[super dealloc];
}

- (void) playEffect:(int) effectId {
	SoundEngine_StartEffect(_sounds[effectId]);
}

#pragma mark Singleton stuff

+ (SoundEffectsHolder *)sharedInstance {
    @synchronized(self) {
        if (sharedSoundEffectsDelegate == nil) {
            [[self alloc] init];
        }
    }
    return sharedSoundEffectsDelegate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedSoundEffectsDelegate == nil) {
            sharedSoundEffectsDelegate = [super allocWithZone:zone];
            return sharedSoundEffectsDelegate;
        }
    }
	
    return nil;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
	// NOTHING
}

- (id)autorelease {
    return self;
}

@end
