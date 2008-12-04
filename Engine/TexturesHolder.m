//
//  TexturesHolder.m
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TexturesHolder.h"
#import "TMNote.h"
#import "TMFramedTexture.h"
#import "TMAnimatable.h"

// This is a singleton class, see below
static TexturesHolder *sharedTexturesDelegate = nil;

@implementation TexturesHolder

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	NSLog(@"Loading textures...");
	
	char *arrowNames[9] = {
		"4th", "8th", "12th", "16th", "24th",
		"32nd", "48th", "64th", "192nd"
	};
	
	// FIXME: not hardcoded!
	NSString* themeDir = @"default";
	NSString* skin = @"itg";
	
	// Load main background
	_textures[kTexture_Background] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/%@", themeDir, @"Background.png"]]];
	
	//Load other textures
	_textures[kTexture_MainMenuButtonPlay] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/%@", themeDir, @"buttonPlay.png"]]];
	_textures[kTexture_MainMenuButtonOptions] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/%@", themeDir, @"buttonOptions.png"]]];
	_textures[kTexture_MainMenuButtonCredits] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/%@", themeDir, @"buttonCredits.png"]]];

	_textures[kTexture_SampleAnimation] = [[TMAnimatable alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/%@", themeDir, @"sampleAnimation_1x4.png"]] columns:4 andRows:1];
	_textures[kTexture_SongSelectionBackground] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/%@", themeDir, @"songSelectionBackground.png"]]];
	_textures[kTexture_SongSelectionWheelItem] = [[TMFramedTexture alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/%@", themeDir, @"songSelectionWheelItem_1x2.png"]] columns:2 andRows:1];
	_textures[kTexture_SongSelectionWheelItemSelected] = [[TMFramedTexture alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"themes/%@/%@", themeDir, @"songSelectionWheelItemSelected_1x2.png"]] columns:2 andRows:1];
	
	int arrowIdx = kBeatType_4th;
	int totalNotes = kNumBeatTypes*4;
	int nameIdx = 0;

	// Now load all arrow images which depend on the noteskin
	for(; arrowIdx < totalNotes; arrowIdx+=4, nameIdx++){ 
	
		NSLog(@"load arrows for %@ with idx: %d and name: '%s'", skin, arrowIdx, arrowNames[nameIdx]);
		_textures[arrowIdx] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/left_%s.png", skin, arrowNames[nameIdx]]]];
		_textures[arrowIdx+1] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/right_%s.png", skin, arrowNames[nameIdx]]]];
		_textures[arrowIdx+2] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/down_%s.png", skin, arrowNames[nameIdx]]]];
		_textures[arrowIdx+3] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/up_%s.png", skin, arrowNames[nameIdx]]]];
	}
	
	_textures[kTexture_Base] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/base.png", skin]]];
	_textures[kTexture_BaseDark] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/base_dark.png", skin]]];
	_textures[kTexture_HoldBody] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/hold_body.png", skin]]];
	_textures[kTexture_HoldBottom] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/hold_bottom.png", skin]]];

	
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

- (Texture2D*) getArrowTextureForType:(TMBeatType)type andDir:(TMNoteDirection) dir {
	TMTexture idx = kTexture_LeftArrow_4 + (type * 4) + dir;
	return [self getTexture:idx];
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
