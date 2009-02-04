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
	m_pTextures[kTexture_SongPlayBackgroundIndex] = [[Texture2D alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"songPlayBackground_index.png"]]];
	m_pTextures[kTexture_SongPlayBackgroundSpread] = [[Texture2D alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"songPlayBackground_spread.png"]]];
	m_pTextures[kTexture_CreditsBackground] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"creditsBackground.png"]]];
	m_pTextures[kTexture_SongSelectionBackground] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"songSelectionBackground.png"]]];	
	
	//Load other textures
	m_pTextures[kTexture_MainMenuBackground] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"mainMenuBackground.png"]]];
	m_pTextures[kTexture_MainMenuButtonPlay] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"buttonPlay.png"]]];
	m_pTextures[kTexture_MainMenuButtonOptions] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"buttonOptions.png"]]];
	m_pTextures[kTexture_MainMenuButtonCredits] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"buttonCredits.png"]]];

	m_pTextures[kTexture_SongSelectionWheelItem] = [[TMFramedTexture alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"songSelectionWheelItem_1x2.png"]] columns:2 andRows:1];
	m_pTextures[kTexture_SongSelectionWheelItemSelected] = [[TMFramedTexture alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"songSelectionWheelItemSelected_1x2.png"]] columns:2 andRows:1];
	m_pTextures[kTexture_SongSelectionWheelLoadingAvatar] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"songSelectionWheelLoadingAvatar.png"]]];
	m_pTextures[kTexture_SongSelectionSpeedToggler] = [[TMFramedTexture alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"songSelectionSpeedToggler_1x3.png"]] columns:3 andRows:1];
	
	m_pTextures[kTexture_LifeBarFrame] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"lifeBarFrame.png"]]];
	m_pTextures[kTexture_LifeBarBackground] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"lifeBarBackground.png"]]];
	m_pTextures[kTexture_LifeBarNormal] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"lifeBarNormal.png"]]];
	m_pTextures[kTexture_LifeBarHot] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"lifeBarHot.png"]]];

	// Load judgement sprites
	m_pTextures[kTexture_Judgement] = [[Judgement alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"judgement_6x1.png"]] columns:1 andRows:6];
	m_pTextures[kTexture_HoldJudgement] = [[HoldJudgement alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/Graphics/%@", themeDir, @"holdJudgement_2x1.png"]] columns:1 andRows:2];
	
	// Load 8x8 texture for tap notes
	m_pTextures[kTexture_TapNote] = [[TapNote alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/downTapNote_8x8.png", skin]] columns:8 andRows:8];
	
	m_pTextures[kTexture_GoReceptor] = [[Receptor alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/downGoReceptor.png", skin]] columns:1 andRows:1];
	m_pTextures[kTexture_TapExplosionDim] = [[TMFramedTexture alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/downTapExplosionDim.png", skin]] columns:1 andRows:1];
	m_pTextures[kTexture_TapExplosionBright] = [[TMFramedTexture alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/downTapExplosionBright.png", skin]] columns:1 andRows:1];
	
	m_pTextures[kTexture_HoldBodyActive] = [[HoldNote alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/downHoldBodyActive.png", skin]] columns:1 andRows:1];
	m_pTextures[kTexture_HoldBottomCapActive] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/downHoldBottomCapActive.png", skin]]];
	m_pTextures[kTexture_HoldBodyInactive] = [[HoldNote alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/downHoldBodyInactive.png", skin]] columns:1 andRows:1];
	m_pTextures[kTexture_HoldBottomCapInactive] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/downHoldBottomCapInactive.png", skin]]];
	
	NSLog(@"Done.");
	
	return self;
}

- (void) dealloc {
	int i;

	for(i=0; i<kNumTextures; i++){
		[m_pTextures[i] release];
	}
	
	[super dealloc];
}

- (Texture2D*) getTexture:(TMTexture) textureId {
	if(textureId < kNumTextures)
		return m_pTextures[textureId];
	
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
