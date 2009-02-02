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
	
	// Load backgrounds
	_textures[kTexture_SongPlayBackgroundIndex] = [[Texture2D alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"songPlayBackground_index.png"]]];
	_textures[kTexture_SongPlayBackgroundSpread] = [[Texture2D alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"songPlayBackground_spread.png"]]];
	_textures[kTexture_CreditsBackground] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"creditsBackground.png"]]];
	_textures[kTexture_SongSelectionBackground] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"songSelectionBackground.png"]]];	
	
	//Load other textures
	_textures[kTexture_MainMenuBackground] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"mainMenuBackground.png"]]];
	_textures[kTexture_MainMenuButtonPlay] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"buttonPlay.png"]]];
	_textures[kTexture_MainMenuButtonOptions] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"buttonOptions.png"]]];
	_textures[kTexture_MainMenuButtonCredits] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"buttonCredits.png"]]];

	_textures[kTexture_SongSelectionWheelItem] = [[TMFramedTexture alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"songSelectionWheelItem_1x2.png"]] columns:2 andRows:1];
	_textures[kTexture_SongSelectionWheelItemSelected] = [[TMFramedTexture alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"songSelectionWheelItemSelected_1x2.png"]] columns:2 andRows:1];
	_textures[kTexture_SongSelectionWheelLoadingAvatar] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"songSelectionWheelLoadingAvatar.png"]]];
	_textures[kTexture_SongSelectionSpeedToggler] = [[TMFramedTexture alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"songSelectionSpeedToggler_1x3.png"]] columns:3 andRows:1];
	
	_textures[kTexture_LifeBarFrame] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"lifeBarFrame.png"]]];
	_textures[kTexture_LifeBarBackground] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"lifeBarBackground.png"]]];
	_textures[kTexture_LifeBarNormal] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"lifeBarNormal.png"]]];
	_textures[kTexture_LifeBarHot] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"lifeBarHot.png"]]];

	// Load judgement sprites
	_textures[kTexture_Judgement] = [[Judgement alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"judgement_6x1.png"]] columns:1 andRows:6];
	_textures[kTexture_HoldJudgement] = [[HoldJudgement alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"holdJudgement_2x1.png"]] columns:1 andRows:2];
	
	// Load 8x8 texture for tap notes
	_textures[kTexture_TapNote] = [[TapNote alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/downTapNote_8x8.png", skin]] columns:8 andRows:8];
	
	_textures[kTexture_GoReceptor] = [[Receptor alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/downGoReceptor.png", skin]] columns:1 andRows:1];
	_textures[kTexture_TapExplosionDim] = [[TMFramedTexture alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/downTapExplosionDim.png", skin]] columns:1 andRows:1];
	_textures[kTexture_TapExplosionBright] = [[TMFramedTexture alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/downTapExplosionBright.png", skin]] columns:1 andRows:1];
	
	_textures[kTexture_HoldBodyActive] = [[HoldNote alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/downHoldBodyActive.png", skin]] columns:1 andRows:1];
	_textures[kTexture_HoldBottomCapActive] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/downHoldBottomCapActive.png", skin]]];
	_textures[kTexture_HoldBodyInactive] = [[HoldNote alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/downHoldBodyInactive.png", skin]] columns:1 andRows:1];
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
