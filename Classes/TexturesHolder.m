//
//  TexturesHolder.m
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TexturesHolder.h"
#import "TMNote.h"

// This is a singleton class, see below
static TexturesHolder *sharedTexturesDelegate = nil;

@implementation TexturesHolder

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	NSLog(@"Loading textures...");
	
	char *arrowNames[9] = {
		"4th", "8th", "12th", "16th", "24th"
		"32nd", "48th", "64th", "192nd"
	};
	
	//Load the background texture and configure it
	_textures[kTexture_Title] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"Background.png"]];
	
	//Load other textures
	_textures[kTexture_Background] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"Background.png"]];
	
	// FIXME: not hardcoded!
	NSString* skin = @"itg";
	
	int arrowIdx = kNoteType_4th;
	int totalNotes = kNumNoteTypes*4;
	int nameIdx = 0;
	
	for(; arrowIdx < totalNotes; arrowIdx+=4, nameIdx++){ 
	
		_textures[arrowIdx] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/left_%s.png", skin, arrowNames[nameIdx]]]];
		_textures[arrowIdx+1] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/right_%s.png", skin, arrowNames[nameIdx]]]];
		_textures[arrowIdx+2] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/down_%s.png", skin, arrowNames[nameIdx]]]];
		_textures[arrowIdx+3] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:[NSString stringWithFormat:@"noteskins/%@/up_%s.png", skin, arrowNames[nameIdx]]]];
	}
	
	_textures[kTexture_Base] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"base.png"]];
	
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

- (Texture2D*) getArrowTextureForType:(TMNoteType)type andDir:(TMNoteDirection) dir {
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
