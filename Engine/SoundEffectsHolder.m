//
//  SoundEffectsHolder.m
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "SoundEffectsHolder.h"
#import "TMSoundEngine.h"
#import "SettingsEngine.h"

// This is a singleton class, see below
static SoundEffectsHolder *sharedSoundEffectsDelegate = nil;

@implementation SoundEffectsHolder

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	// FIXME: hardcode
	NSString* themeDir = @"default";
	
	[TMSoundEngine sharedInstance];
		
	// Set the master volume from settings
	float volume = [[SettingsEngine sharedInstance] getFloatValue:@"sound"];
	TMLog(@"Done.");
	
	return self;
}

- (void) dealloc {
	// SoundEngine_Teardown();	
	[[TMSoundEngine sharedInstance] shutdownOpenAL];
	
	[super dealloc];
}

- (void) playEffect:(int) effectId {
	// SoundEngine_StartEffect(m_uiSounds[effectId]);
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
