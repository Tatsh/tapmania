//
//  SongsDirectoryCache.m
//  TapMania
//
//  Created by Alex Kremer on 07.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "SongsDirectoryCache.h"

#import "TMSong.h"

#include <CommonCrypto/CommonDigest.h>

#define CHUNK_SIZE 131072 // 128kb

// This is a singleton class, see below
static SongsDirectoryCache *sharedSongsDirCacheDelegate = nil;

@interface SongsDirectoryCache (Private) 
- (NSMutableDictionary*) getCatalogueCache;
- (void) writeCatalogueCache;

- (BOOL) dirIsSimfile:(NSString*)path;
- (void) addSongFromDir:(NSString*)path;

+ (NSString*)fileMD5:(NSString*)path;
+ (NSString*)dirMD5:(NSString*)path;
@end

@implementation SongsDirectoryCache

@synthesize m_idDelegate;
@synthesize m_bCatalogueIsEmpty;

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	m_aAvailableSongs = [[NSMutableArray arrayWithCapacity:10] retain];
	m_bCatalogueIsEmpty = NO;
	
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
		/*
		 Version 0.1.6 introduces a webserver solution for song upload/management.
		 Therefore the error should not arise.
		 However we need to disable the Play button in the main menu so that
		 the user will need to upload songs first if none are available.
		*/
		 
		if([songsDirContents count] == 0) {
			m_bCatalogueIsEmpty = YES;
		}
		
		// Try to read the catalogue file
		m_pCatalogueCache = [[SongsDirectoryCache sharedInstance] getCatalogueCache];		
		
		// Renew the cache
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

				TMLog(@"Music file path: %@", musicFilePath);
				
				// Make the files relative to the songs dir
				musicFilePath = [musicFilePath stringByReplacingOccurrencesOfString:m_sSongsDir withString:@""];
				stepsFilePath = [stepsFilePath stringByReplacingOccurrencesOfString:m_sSongsDir withString:@""];
				
				if([m_pCatalogueCache valueForKey:songDirName] != nil) {
					TMLog(@"Catalogue file has this file already!");
					TMSong* song = [m_pCatalogueCache valueForKey:songDirName];
					
					// Check hash
					NSString* songHash = [SongsDirectoryCache dirMD5:curPath];
					TMLog(@"GOT HASH: '%@'", songHash);
					TMLog(@"CACHED HASH IS: '%@'", song.m_sHash);
					
					if(! [songHash isEqualToString:song.m_sHash]) {
						TMLog(@"Hash missmatch! Must reload!");
						[song release];
						song = [[TMSong alloc] initWithStepsFile:stepsFilePath andMusicFile:musicFilePath andDir:songDirName];				
						
						// Also update in cache
						[m_pCatalogueCache setObject:song forKey:songDirName];
					}
					
					[m_aAvailableSongs addObject:song];
					
				} else {
					TMSong* song = [[TMSong alloc] initWithStepsFile:stepsFilePath andMusicFile:musicFilePath andDir:songDirName];				
					
					// Calculate the hash and store it
					NSString* songHash = [SongsDirectoryCache dirMD5:curPath];
					TMLog(@"GOT HASH: '%@'", songHash);
					
					song.m_sHash = songHash;

					TMLog(@"Song ready to be added to list!!");
					[m_aAvailableSongs addObject:song];
					
					// Add to cache
					[m_pCatalogueCache setObject:song forKey:songDirName];					
				}
												
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
	
	// Write cache file
	[[SongsDirectoryCache sharedInstance] writeCatalogueCache];
	
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
	int i = [m_aAvailableSongs indexOfObject:song];
	if(i == [m_aAvailableSongs count]-1) i = 0;
	else ++i;
	
	return [m_aAvailableSongs objectAtIndex:i];
}

- (TMSong*) getSongPrevFrom:(TMSong*)song {
	
	int i = [m_aAvailableSongs indexOfObject:song];
	if(i == 0) i = [m_aAvailableSongs count] -1;
	else --i;
	
	return [m_aAvailableSongs objectAtIndex:i];
}

- (void) addSongsFrom:(NSString*)rootDir {
	// This is usually called after a smzip/zip was extracted
	// We will just recursively iterate over the whole package and try to find
	// all complete simfiles.
	NSFileManager* fMan = [NSFileManager defaultManager];
	TMLog(@"Going to test dir '%@' for simfiles...", rootDir);
	
	// Check whether this dir is a simfile dir already
	if( ![[rootDir lastPathComponent] hasPrefix:@"__MACOSX"] && [self dirIsSimfile:rootDir] ) {
		TMLog(@"Found a potential simfile directory. try to add files from there..");
		[self addSongFromDir:rootDir];

		return;
	}
		
	// Otherwise we will need to iterate over the contents to see if we can
	// find directories with simfiles
	NSArray* rootDirContents = [fMan directoryContentsAtPath:rootDir];	

	// If the dir is empty, leave
	if([rootDirContents count] == 0) {
		return;
	}
	
	// Iterate over the contents
	for (NSString* item in rootDirContents) {
		if( [item hasPrefix:@"__MACOSX"] ) 
			continue;
		
		BOOL isDir = NO;
		NSString* path = [rootDir stringByAppendingPathComponent:item];
		
		if([fMan fileExistsAtPath:path isDirectory:&isDir] && isDir) {
			TMLog(@"Recursively try '%@'...", path);
			[self addSongsFrom:path];
		}
	}
}

- (BOOL) dirIsSimfile:(NSString*)path {
	NSArray* contents = [[NSFileManager defaultManager] directoryContentsAtPath:path];	
	NSString* file;

	TMLog(@"Test dir '%@' for simfile contents...", path);
	
	// Need at least music and steps
	BOOL stepsFound, musicFound;
	stepsFound = musicFound = NO;
	
	for (NSString* file in contents) {		
		TMLog(@"Examine file/dir: %@", file);
		
		if([[file lowercaseString] hasSuffix:@".dwi"] || [[file lowercaseString] hasSuffix:@".sm"]) {			
			stepsFound = YES;
		} else if([[file lowercaseString] hasSuffix:@".mp3"] || [[file lowercaseString] hasSuffix:@".ogg"]) {
			musicFound = YES;
		}
	}
	
	return musicFound && stepsFound;
}

- (void) addSongFromDir:(NSString*)path {
	NSString* curPath = [m_sSongsDir stringByAppendingPathComponent:[path lastPathComponent]];
	BOOL isDir;
	
	// Check whether the Song already exists in the catalogue
	if( [[NSFileManager defaultManager] fileExistsAtPath:curPath isDirectory:&isDir] ) {
		// TODO: handle situation. report to user.
		return;
	}
	
	// TODO handle errors
	NSError* err;

	if([[NSFileManager defaultManager] copyItemAtPath:path toPath:curPath error:&err]) {
		// TODO: Ok, now add to library
	}
}

- (void) deleteSong:(NSString*)songDirName {
	TMSong* foundSong = nil;
	
	for(TMSong* song in m_aAvailableSongs) {
		if([song.m_sSongDirName isEqualToString:songDirName]) {
			foundSong = song;
			break;
		}
	}
	
	// Only delete found songs to prevent any harm
	if(foundSong == nil) 
		return;
	
	// Remove from current list
	[m_aAvailableSongs removeObject:foundSong];
	if([m_aAvailableSongs count] == 0) {
		m_bCatalogueIsEmpty = YES;
	}
	
	// Update cache
	[m_pCatalogueCache removeObjectForKey:songDirName];
	[self writeCatalogueCache];
	
	// Remove the directory on the FS
	NSError* err;
	[[NSFileManager defaultManager] removeItemAtPath:[m_sSongsDir stringByAppendingPathComponent:songDirName] error:&err];
}

- (NSMutableDictionary*) getCatalogueCache {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	
	if([paths count] > 0) {
		NSString * dir = [paths objectAtIndex:0]; 
		NSString* catalogueFile = [[dir stringByAppendingPathComponent:kCatalogueFileName] retain];
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:catalogueFile]) {
			return [[NSMutableDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:catalogueFile]];
		}
	}
	
	TMLog(@"Catalogue cache is empty! Returning default empty cache instance...");
	return [[NSMutableDictionary alloc] init];
}

- (void) writeCatalogueCache {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	
	if([paths count] > 0) {
		NSString * dir = [paths objectAtIndex:0]; 
		NSString* catalogueFile = [[dir stringByAppendingPathComponent:kCatalogueFileName] retain];

		TMLog(@"Write catalogue to: %@", catalogueFile);
		
		if( YES == [NSKeyedArchiver archiveRootObject:m_pCatalogueCache toFile:catalogueFile] ) {
			TMLog(@"Successfully written the catalogue!");
		} else {
			TMLog(@"Too bad. Failed to write catalogue...");
		}
	}
}

+(NSString*)fileMD5:(NSString*)path {
	NSDictionary *fileAttributes = [[NSFileManager defaultManager] fileAttributesAtPath:path traverseLink:YES];
		
	if (fileAttributes == nil) {
		return @"Can't get file md5";
	}

	NSNumber *fileSize;
	NSDate *fileModDate;
	NSString* result = @"";
	
	CC_MD5_CTX md5;
	CC_MD5_Init(&md5);
	
	if (fileSize = [fileAttributes objectForKey:NSFileSize]) {
		result = [result stringByAppendingString:[fileSize stringValue]];
	}
	
	if (fileModDate = [fileAttributes objectForKey:NSFileModificationDate]) {
		result = [result stringByAppendingString:[fileSize stringValue]];
	}
	
	CC_MD5_Update(&md5, [result UTF8String], [result length]);
	
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5_Final(digest, &md5);

	NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
				   digest[0], digest[1], 
				   digest[2], digest[3],
				   digest[4], digest[5],
				   digest[6], digest[7],
				   digest[8], digest[9],
				   digest[10], digest[11],
				   digest[12], digest[13],
				   digest[14], digest[15]];
	return s;
}

+ (NSString*)dirMD5:(NSString*)path {
	NSArray* dirContents = [[NSFileManager defaultManager] directoryContentsAtPath:path];
	
	if([dirContents count] == 0) {
		return nil;
	}
	
	NSString* result = @"";
	int i;
	
	// Accumulate md5s of all files in the dir
	for(i = 0; i<[dirContents count]; i++) {		
		NSString* md5 = [SongsDirectoryCache fileMD5:[path stringByAppendingPathComponent:[dirContents objectAtIndex:i]]];
		result = [result stringByAppendingString:md5];
	}
	
	// Create one md5 from the ruslt string
	CC_MD5_CTX md5;
	CC_MD5_Init(&md5);
	CC_MD5_Update(&md5, [result UTF8String], [result length]);
	
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5_Final(digest, &md5);
	NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
				   digest[0], digest[1], 
				   digest[2], digest[3],
				   digest[4], digest[5],
				   digest[6], digest[7],
				   digest[8], digest[9],
				   digest[10], digest[11],
				   digest[12], digest[13],
				   digest[14], digest[15]];

	return s;
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
