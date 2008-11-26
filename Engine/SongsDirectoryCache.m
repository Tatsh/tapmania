//
//  SongsDirectoryCache.m
//  TapMania
//
//  Created by Alex Kremer on 07.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "SongsDirectoryCache.h"

#import "TMSong.h"

// This is a singleton class, see below
static SongsDirectoryCache *sharedSongsDirCacheDelegate = nil;

@implementation SongsDirectoryCache

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	NSLog(@"Caching songs in 'Songs' dir...");
	
	int i;	
	availableSongs = [[NSMutableArray arrayWithCapacity:10] retain];
	
	// Get songs directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	if([paths count] > 0) {
		NSString * dir = [paths objectAtIndex:0]; 
		songsDir = [[dir stringByAppendingPathComponent:@"Songs"] retain];
		
		NSLog(@"Songs dir at: %@", songsDir);		
		
		// Read all songs in the dir and cache them
		NSArray* songsDirContents = [[NSFileManager defaultManager] directoryContentsAtPath:songsDir];
		
		
		for(i = 0; i<[songsDirContents count]; i++) {
		
			NSString* curPath = [songsDir stringByAppendingPathComponent:[songsDirContents objectAtIndex:i]];
			NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:curPath];
			NSString* file;
		
			NSString* stepsFilePath = nil;
			NSString* musicFilePath = nil;			
			
			while (file = [dirEnum nextObject]) {
				if([file hasSuffix:@".dwi"] || [file hasSuffix:@".DWI"]) {
					NSLog(@"DWI file found: %@", file);
					stepsFilePath = [curPath stringByAppendingPathComponent:file];
				}
				
				if([file hasSuffix:@".mp3"] || [file hasSuffix:@".MP3"]) {
					NSLog(@"Found music file: %@", file);
					musicFilePath = [curPath stringByAppendingPathComponent:file];
				}
			}
			
			// Now try to parse if found everything
			if(stepsFilePath != nil && musicFilePath != nil){
				
				// Parse very basic info from this file
				NSLog(@"Parsing song from %@...", stepsFilePath);
				TMSong* song = [[TMSong alloc] initWithStepsFile:stepsFilePath andMusicFile:musicFilePath];
				NSLog(@"Done.");			
			
				[availableSongs addObject:song];
				
			} else {
				NSLog(@"Error: steps file or music file not found for song dir '%@'! abort.", curPath);
			}
		}
	} else {
		NSException *ex = [NSException exceptionWithName:@"SongsDirNotFound" reason:@"Songs directory couldn't be found!" userInfo:nil];
		@throw ex;
	}
		
	NSLog(@"Done.");
	
	return self;
}


- (NSArray*) getSongList {
	return availableSongs;
}

- (NSString*) getSongsPath {
	return songsDir;
}

- (void) dealloc {
	[songsDir release];
	[availableSongs release];
	
	[super dealloc];
}


#pragma mark Singleton stuff

+ (SongsDirectoryCache *)sharedInstance {
    @synchronized(self) {
        if (sharedSongsDirCacheDelegate == nil) {
            [[self alloc] init];
        }
    }
    return sharedSongsDirCacheDelegate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedSongsDirCacheDelegate	== nil) {
            sharedSongsDirCacheDelegate = [super allocWithZone:zone];
            return sharedSongsDirCacheDelegate;
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
