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

@synthesize delegate;

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	availableSongs = [[NSMutableArray arrayWithCapacity:10] retain];
	
	return self;
}


- (void) cacheSongs {
	NSLog(@"Caching songs in 'Songs' dir...");
	
	int i;	
	[availableSongs removeAllObjects];	// Clear the list if we had filled it before
	
	// Get songs directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	if([paths count] > 0) {
		NSString * dir = [paths objectAtIndex:0]; 
		songsDir = [[dir stringByAppendingPathComponent:@"Songs"] retain];
		
		// Create the songs dir if missing
		if(! [[NSFileManager defaultManager] isReadableFileAtPath:songsDir]){
			[[NSFileManager defaultManager] createDirectoryAtPath:songsDir attributes:nil];
		}
		
		NSLog(@"Songs dir at: %@", songsDir);		
		
		// Read all songs in the dir and cache them
		NSArray* songsDirContents = [[NSFileManager defaultManager] directoryContentsAtPath:songsDir];
		
		// Raise error if empty songs dir
		if([songsDirContents count] == 0) {
			if(delegate != nil) {
				[delegate songLoaderError:@"Songs directory is empty"];
			}
			
			return;
		}
		
		for(i = 0; i<[songsDirContents count]; i++) {
			
			NSString* songDirName = [songsDirContents objectAtIndex:i];
			NSString* curPath = [songsDir stringByAppendingPathComponent:songDirName];
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
				if(delegate != nil) {
					[delegate startLoadingSong:songDirName];
				}

				TMSong* song = [[TMSong alloc] initWithStepsFile:stepsFilePath andMusicFile:musicFilePath];				
				[availableSongs addObject:song];
				
				if(delegate != nil) {
					[delegate doneLoadingSong:songDirName];
				}								
			} else {
				if(delegate != nil) {
					[delegate errorLoadingSong:songDirName withReason:@"Steps file or Music file not found for this song. ignoring."];
				}			
			}
		}
	} else {
		NSException *ex = [NSException exceptionWithName:@"SongsDirNotFound" reason:@"Songs directory couldn't be found!" userInfo:nil];
		@throw ex;
	}
	
	// Tell the user that we are done
	if(delegate != nil) {
		[delegate songLoaderFinished];
	}
	
	NSLog(@"Done.");	
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
