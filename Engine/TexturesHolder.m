//
//  TexturesHolder.m
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TexturesHolder.h"

// This is a singleton class, see below
static TexturesHolder *sharedTexturesDelegate = nil;

@implementation TexturesHolder

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	NSLog(@"Loading textures...");
	
	// FIXME: not hardcoded!
	NSString* themeDir = @"default";
	NSString* skin = @"default";
	
	// Load main background
	_textures[kTexture_Background] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/%@", themeDir, @"Background.png"]]];
	
	//Load other textures
	_textures[kTexture_MainMenuButtonPlay] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/%@", themeDir, @"buttonPlay.png"]]];
	_textures[kTexture_MainMenuButtonOptions] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/%@", themeDir, @"buttonOptions.png"]]];
	_textures[kTexture_MainMenuButtonCredits] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/%@", themeDir, @"buttonCredits.png"]]];

	_textures[kTexture_SongSelectionBackground] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/%@", themeDir, @"songSelectionBackground.png"]]];
	_textures[kTexture_SongSelectionWheelItem] = [[TMFramedTexture alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/%@", themeDir, @"songSelectionWheelItem_1x2.png"]] columns:2 andRows:1];
	_textures[kTexture_SongSelectionWheelItemSelected] = [[TMFramedTexture alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/%@", themeDir, @"songSelectionWheelItemSelected_1x2.png"]] columns:2 andRows:1];
	_textures[kTexture_SongSelectionWheelLoadingAvatar] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/%@", themeDir, @"songSelectionWheelLoadingAvatar.png"]]];
	
	// Load 8x8 texture for tap notes
	_textures[kTexture_TapNote] = [[TapNote alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/downTapNote_8x8.png", skin]] columns:8 andRows:8];
	
	_textures[kTexture_GoReceptor] = [[Receptor alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/downGoReceptor.png", skin]] columns:1 andRows:1];
	_textures[kTexture_HoldBodyActive] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/downHoldBodyActive.png", skin]]];
	_textures[kTexture_HoldBottomCapActive] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/downHoldBottomCapActive.png", skin]]];
	_textures[kTexture_HoldBodyInactive] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/downHoldBodyInactive.png", skin]]];
	_textures[kTexture_HoldBottomCapInactive] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/downHoldBottomCapInactive.png", skin]]];
	
	NSLog(@"Done.");
	
	return self;
}

- (void) dealloc {
	int i;

	for(i=0; i<kNumTextures; i++){
		[_textures[i] release];
	}
	
	[super dealloc];
}

- (Texture2D*) getTexture:(TMTexture) textureId {
	if(textureId < kNumTextures)
		return _textures[textureId];
	
	return nil;
}

#pragma mark Singleton stuff

+ (TexturesHolder *)sharedInstance {
    @synchronized(self) {
        if (sharedTexturesDelegate == nil) {
            [[self alloc] init];
        }
    }
    return sharedTexturesDelegate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedTexturesDelegate == nil) {
            sharedTexturesDelegate = [super allocWithZone:zone];
            return sharedTexturesDelegate;
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
