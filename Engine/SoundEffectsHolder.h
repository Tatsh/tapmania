//
//  SoundEffectsHolder.h
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
	kSound_Clap = 0,
	kSound_Failure,
	kSound_Success,
	kNumSounds
};

@interface SoundEffectsHolder : NSObject {
	UInt32					_sounds[kNumSounds];
}

- (void) playEffect:(int) effectId;

+ (SoundEffectsHolder *)sharedInstance;

@end
