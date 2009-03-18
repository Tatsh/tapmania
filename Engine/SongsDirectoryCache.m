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

@synthesize m_idDelegate;

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	m_aAvailableSongs = [[NSMutableArray arrayWithCapacity:10] retain];
	
	return self;
}


- (void) cacheSongs {
	TMLog(@"Caching songs in 'Songs' dir...");
	
	int i;	
	[m_aAvailableSongs removeAllObjects];	// Clear the list if we had filled it before
	
	// Get songs directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	if([paths count] > 0) {
		NSString * dir = [paths objectAtIndex:0]; 
		m_sSongsDir = [[dir stringByAppendingPathComponent:@"Songs"] retain];
		
		// Create the songs dir if missing
		if(! [[NSFileManager defaultManager] isReadableFileAtPath:m_sSongsDir]){
			[[NSFileManager defaultManager] createDirectoryAtPath:m_sSongsDir attributes:nil];
		}
		
		TMLog(@"Songs dir at: %@", m_sSongsDir);		
		
		// Read all songs in the dir and cache them
		NSArray* songsDirContents = [[NSFileManager defaultManager] directoryContentsAtPath:m_sSongsDir];
		
		// Raise error if empty songs dir
		if([songsDirContents count] == 0) {
			if(m_idDelegate != nil) {
				[m_idDelegate songLoaderError:@"No songs uploaded! read the manual"];
			}
			
			return;
		}
		
		for(i = 0; i<[songsDirContents count]; i++) {
			
			TMLog(@"Pick a song to load...");
			
			NSString* songDirName = [songsDirContents objectAtIndex:i];
			NSString* curPath = [m_sSongsDir stringByAppendingPathComponent:songDirName];
			NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:curPath];
			NSString* file;
			
			NSString* stepsFilePath = nil;
			
			NSString* musicFilePath = nil;			
			
			TMLog(@"Found some path.. now check contents...");
			
			while (file = [dirEnum nextObject]) {
				if([[file lowercaseString] hasSuffix:@".dwi"]) {
					
					// SM format should be picked if both dwi and sm available					
					TMLog(@"DWI file found: %@", file);
					if(stepsFilePath == nil) {
						stepsFilePath = [curPath stringByAppendingPathComponent:file];
					} else {
						TMLog(@"Ignoring because SM is used already...");
					}
				} else if([[file lowercaseString] hasSuffix:@".sm"]) {
					
					// SM format should be picked if both dwi and sm available
					TMLog(@"SM file found: %@", file);
					stepsFilePath = [curPath stringByAppendingPathComponent:file];						
				} else if([[file lowercaseString] hasSuffix:@".mp3"]) {
					
					// we support mp3 files					
					TMLog(@"Found music file (MP3): %@", file);
					musicFilePath = [curPath stringByAppendingPathComponent:file];
				} else if([[file lowercaseString] hasSuffix:@".ogg"]) {
					
					// and ogg too (in future :P)
					TMLog(@"Found music file (OGG): %@", file);
					musicFilePath = [curPath stringByAppendingPathComponent:file];
				}
			}
			
			// Now try to parse if found everything
			if(stepsFilePath != nil && musicFilePath != nil){
				
				// Parse very basic info from this file
				if(m_idDelegate != nil) {
					[m_idDelegate startLoadingSong:songDirName];
				}

				TMSong* song = [[TMSong alloc] initWithStepsFile:[stepsFilePath copy] andMusicFile:[musicFilePath copy]];				
				
				TMLog(@"Song ready to be added to list!!");
				[m_aAvailableSongs addObject:song];
				
				if(m_idDelegate != nil) {
					[m_idDelegate doneLoadingSong:songDirName];
				}								
			} else {
				if(m_idDelegate != nil) {
					[m_idDelegate errorLoadingSong:songDirName withReason:@"Steps file or Music file not found for this song. ignoring."];
				}			
			}
		}
	} else {
		NSException *ex = [NSException exceptionWithName:@"SongsDirNotFound" reason:@"Songs directory couldn't be found!" userInfo:nil];
		@throw ex;
	}
	
	// Tell the user that we are done
	if(m_idDelegate != nil) {
		[m_idDelegate songLoaderFinished];
	}
	
	TMLog(@"Done.");	
}

- (NSArray*) getSongList {
	return m_aAvailableSongs;
}

- (NSString*) getSongsPath {
	return m_sSongsDir;
}

- (TMSong*) getSongNextTo:(TMSong*)song {
	int i;
	for(i=0; i<[m_aAvailableSongs count]; ++i) {

		// We search by memory addres
		if([m_aAvailableSongs objectAtIndex:i] == song) {
			if(i == [m_aAvailableSongs count]-1) {
				i = 0; 
			} else {
				++i;
			}
			
			return [m_aAvailableSongs objectAtIndex:i];
		}
	}
	
	return nil;	// Not found
}

- (TMSong*) getSongPrevFrom:(TMSong*)song {
	int i;
	for(i=0; i<[m_aAvailableSongs count]; ++i) {
		
		// We search by memory addres
		if([m_aAvailableSongs objectAtIndex:i] == song) {
			if(i == 0) {
				i = [m_aAvailableSongs count]-1; 
			} else {
				--i;
			}
			
			return [m_aAvailableSongs objectAtIndex:i];
		}
	}
	
	return nil;	// Not found	
}

- (void) dealloc {
	[m_sSongsDir release];
	[m_aAvailableSongs release];
	
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
