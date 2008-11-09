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
	
	//Load the background texture and configure it
	_textures[kTexture_Title] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"Background.png"]];
	
	//Load other textures
	_textures[kTexture_Background] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"Background.png"]];
	_textures[kTexture_LeftArrow] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"left.png"]];
	_textures[kTexture_RightArrow] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"right.png"]];
	_textures[kTexture_DownArrow] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"down.png"]];
	_textures[kTexture_UpArrow] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"up.png"]];
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
