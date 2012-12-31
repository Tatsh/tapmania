//
//  $Id$
//  SongsDirectoryCache.m
//  TapMania
//
//  Created by Alex Kremer on 07.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "SongsDirectoryCache.h"

#import "TMSong.h"
#import "VersionInfo.h"
#import "DisplayUtil.h"
#import "TMFramedTexture.h"

#include <CommonCrypto/CommonDigest.h>

#define CHUNK_SIZE 131072 // 128kb

// This is a singleton class, see below
static SongsDirectoryCache *sharedSongsDirCacheDelegate = nil;

@interface SongsDirectoryCache (Private)
- (NSMutableDictionary *)getCatalogueCache;

- (void)writeCatalogueCache;

- (BOOL)dirIsSimfile:(NSString *)path;

- (void)addSongFromDir:(NSString *)path;

- (BOOL)addSongToLibrary:(NSString *)curPath fromSongsPathId:(TMSongsPath)pathId useCache:(BOOL)useCache;

+ (NSString *)fileMD5:(NSString *)path;

+ (NSString *)dirMD5:(NSString *)path;
@end

@implementation SongsDirectoryCache

@synthesize m_idDelegate;
@synthesize m_bCatalogueIsEmpty;

- (id)init
{
    self = [super init];
    if ( !self )
    {
        return nil;
    }

    m_aAvailableSongs = [[NSMutableArray arrayWithCapacity:10] retain];
    m_SongsDirs = [[NSMutableDictionary dictionaryWithCapacity:kNumSongsPaths] retain];
    m_bCatalogueIsEmpty = NO;

    // Get songs directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ( [paths count] > 0 )
    {
        NSString *dir = [paths objectAtIndex:0];
        NSString *userSongsDir = [dir stringByAppendingPathComponent:@"Songs"];
        [m_SongsDirs setObject:userSongsDir forKey:[NSNumber numberWithInt:kUserSongsPath]];

        // Create the songs dir if missing
        if ( ![[NSFileManager defaultManager] isReadableFileAtPath:userSongsDir] )
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:userSongsDir attributes:nil];
        }

        TMLog(@"User Songs dir at: %@", userSongsDir);
    }
    else
    {
        NSException *ex = [NSException exceptionWithName:@"SongsDirNotFound"
                                                  reason:@"Songs directory couldn't be found because the system failed to give us a Documents folder!" userInfo:nil];
        @throw ex;
    }

    NSString *bundleSongsDir = [[NSBundle mainBundle] pathForResource:@"Songs" ofType:nil];
    TMLog(@"Bundle Songs dir at: %@", bundleSongsDir);
    [m_SongsDirs setObject:bundleSongsDir forKey:[NSNumber numberWithInt:kBundleSongsPath]];

    NSString *systemSongsDir = [[NSBundle mainBundle] pathForResource:@"SystemSongs" ofType:nil];
    TMLog(@"System Songs dir at: %@", systemSongsDir);
    [m_SongsDirs setObject:systemSongsDir forKey:[NSNumber numberWithInt:kSystemSongsPath]];

    // Try to read the catalogue file
    m_pCatalogueCacheOld = [[SongsDirectoryCache sharedInstance] getCatalogueCache];
    m_pCatalogueCacheNew = [[NSMutableDictionary alloc] initWithCapacity:[m_pCatalogueCacheOld count]];

    return self;
}


- (void)cacheSongs
{
    TMLog(@"Caching songs in 'Songs' dirs...");

    [m_aAvailableSongs removeAllObjects];    // Clear the list if we had filled it before

    NSMutableArray *baseDirs = [[NSMutableArray alloc] init];
    [baseDirs addObject:[NSNumber numberWithInt:kSystemSongsPath]];
    [baseDirs addObject:[NSNumber numberWithInt:kBundleSongsPath]];
    [baseDirs addObject:[NSNumber numberWithInt:kUserSongsPath]];

    NSMutableArray *fullSongDirs = [[NSMutableArray alloc] init];
    for ( int i = 0; i < [baseDirs count]; i++ )
    {
        NSNumber *pId = [baseDirs objectAtIndex:i];
        TMLog(@"SongsDirPathId: %@", pId);
        NSString *baseDir = [self getSongsPath:(TMSongsPath) [pId intValue]];
        TMLog(@"Checking songs dir at: '%@'", baseDir);

        NSArray *relativeSongDirs = [[NSFileManager defaultManager] directoryContentsAtPath:baseDir];
        for ( int j = 0; j < [relativeSongDirs count]; j++ )
        {
            NSString *relativeSongDir = [relativeSongDirs objectAtIndex:j];
            TMLog(@"Found song dir: '%@'", relativeSongDir);

            [fullSongDirs addObject:[baseDir stringByAppendingPathComponent:relativeSongDir]];
            [self addSongToLibrary:[baseDir stringByAppendingPathComponent:relativeSongDir] fromSongsPathId:(TMSongsPath) [pId intValue] useCache:YES];
        }
    }

    // Raise error if empty songs dir
    /*
     Version 0.1.6 introduces a webserver solution for song upload/management.
     Therefore the error should not arise.
     However we need to disable the Play button in the main menu so that
     the user will need to upload songs first if none are available.
    */

    if ( [fullSongDirs count] == 0 )
    {
        m_bCatalogueIsEmpty = YES;
    }

    TMLog(@"Old cache has %d elements", [m_pCatalogueCacheOld count]);

    // Write cache file
    [[SongsDirectoryCache sharedInstance] writeCatalogueCache];

    // Tell the user that we are done
    if ( m_idDelegate != nil )
    {
        [m_idDelegate songLoaderFinished];
    }

    TMLog(@"Done.");
}

- (NSString *)getSongsPath:(TMSongsPath)pathId
{
    return [m_SongsDirs objectForKey:[NSNumber numberWithInt:pathId]];
}

- (NSArray *)getSongList
{
    return m_aAvailableSongs;
}

- (int)songIndex:(NSString *)hash
{
    int idx = 0;

    for ( TMSong *sng in m_aAvailableSongs )
    {
        if ( [hash isEqualToString:sng.m_sHash] )
        {
            return idx;
        }

        ++idx;
    }

    return -1;
}


- (TMSong *)getSongNextTo:(TMSong *)song
{
    int i = [m_aAvailableSongs indexOfObject:song];
    if ( i == [m_aAvailableSongs count] - 1 )
    {
        i = 0;
    }
    else
    {
        ++i;
    }

    return [m_aAvailableSongs objectAtIndex:i];
}

- (TMSong *)getSongPrevFrom:(TMSong *)song
{

    int i = [m_aAvailableSongs indexOfObject:song];
    if ( i == 0 )
    {
        i = [m_aAvailableSongs count] - 1;
    }
    else
    {
        --i;
    }

    return [m_aAvailableSongs objectAtIndex:i];
}

- (void)addSongsFrom:(NSString *)rootDir
{
    // This is usually called after a smzip/zip was extracted
    // We will just recursively iterate over the whole package and try to find
    // all complete simfiles.
    NSFileManager *fMan = [NSFileManager defaultManager];
    TMLog(@"Going to test dir '%@' for simfiles...", rootDir);

    // Check whether this dir is a simfile dir already
    if ( ![[rootDir lastPathComponent] hasPrefix:@"__MACOSX"] && [self dirIsSimfile:rootDir] )
    {
        TMLog(@"Found a potential simfile directory. try to add files from there..");
        [self addSongFromDir:rootDir];

        return;
    }

    // Otherwise we will need to iterate over the contents to see if we can
    // find directories with simfiles
    NSArray *rootDirContents = [fMan directoryContentsAtPath:rootDir];

    // If the dir is empty, leave
    if ( [rootDirContents count] == 0 )
    {
        return;
    }

    // Iterate over the contents
    for ( NSString *item in rootDirContents )
    {
        if ( [item hasPrefix:@"__MACOSX"] )
        {
            continue;
        }

        BOOL isDir = NO;
        NSString *path = [rootDir stringByAppendingPathComponent:item];

        if ( [fMan fileExistsAtPath:path isDirectory:&isDir] && isDir )
        {
            TMLog(@"Recursively try '%@'...", path);
            [self addSongsFrom:path];
        }
    }
}

- (BOOL)dirIsSimfile:(NSString *)path
{
    NSArray *contents = [[NSFileManager defaultManager] directoryContentsAtPath:path];

    TMLog(@"Test dir '%@' for simfile contents...", path);

    // Need at least music and steps
    BOOL stepsFound, musicFound;
    stepsFound = musicFound = NO;

    for ( NSString *file in contents )
    {
        TMLog(@"Examine file/dir: %@", file);

        if ( [[file lowercaseString] hasSuffix:@".dwi"] || [[file lowercaseString] hasSuffix:@".sm"] )
        {
            stepsFound = YES;
        }
        else if ( [[file lowercaseString] hasSuffix:@".mp3"]
#ifdef TM_OGG_ENABLE
				  || [[file lowercaseString] hasSuffix:@".ogg"]
#endif // TM_OGG_ENABLE
                )
        {
            musicFound = YES;
        }
    }

    return musicFound && stepsFound;
}

- (void)addSongFromDir:(NSString *)path
{
    NSString *curPath = [[self getSongsPath:kUserSongsPath] stringByAppendingPathComponent:[path lastPathComponent]];
    BOOL isDir;

    // Check whether the Song already exists in the catalogue
    if ( [[NSFileManager defaultManager] fileExistsAtPath:curPath isDirectory:&isDir] )
    {
        // TODO: handle situation. report to user.
        return;
    }

    // TODO handle errors
    NSError *err;

    if ( [[NSFileManager defaultManager] copyItemAtPath:path toPath:curPath error:&err] )
    {
        if ( [self addSongToLibrary:curPath fromSongsPathId:kUserSongsPath useCache:NO] )
        {
            // Write cache file
            [[SongsDirectoryCache sharedInstance] writeCatalogueCache];
        }
    }
}

- (BOOL)addSongToLibrary:(NSString *)curPath fromSongsPathId:(TMSongsPath)pathId useCache:(BOOL)useCache
{
    NSArray *dirContents = [[NSFileManager defaultManager] directoryContentsAtPath:curPath];
    NSString *songDirName = [curPath lastPathComponent];

    NSString *stepsFilePath = nil;
    NSString *musicFilePath = nil;
    NSString *backgroundFilePath = nil;

    NSString *deviceBgFile = [[NSString stringWithFormat:@"bg-%@.png", [DisplayUtil getDeviceDisplayString]] lowercaseString];

    for ( NSString *file in dirContents )
    {
        if ( [[file lowercaseString] hasSuffix:@".dwi"] )
        {

            // SM format should be picked if both dwi and sm available
            TMLog(@"DWI file found: %@", file);
            if ( stepsFilePath == nil )
            {
                stepsFilePath = [curPath stringByAppendingPathComponent:file];
            }
            else
            {
                TMLog(@"Ignoring because SM is used already...");
            }
        }
        else if ( [[file lowercaseString] hasSuffix:@".sm"] )
        {

            // SM format should be picked if both dwi and sm available
            TMLog(@"SM file found: %@", file);
            stepsFilePath = [curPath stringByAppendingPathComponent:file];
        }
        else if ( [[file lowercaseString] hasSuffix:@".mp3"] )
        {

            // we support mp3 files
            TMLog(@"Found music file (MP3): %@", file);
            musicFilePath = [curPath stringByAppendingPathComponent:file];
        }
#ifdef TM_OGG_ENABLE
		else if([[file lowercaseString] hasSuffix:@".ogg"]) {
			
			// and ogg too (in future :P)
			TMLog(@"Found music file (OGG): %@", file);
			musicFilePath = [curPath stringByAppendingPathComponent:file];
		} 
#endif // TM_OGG_ENABLE
        else if ( [[file lowercaseString] isEqualToString:deviceBgFile] )
        {
            TMLog(@"Found resolution-perfect graphic file (PNG): %@", file);
            backgroundFilePath = [curPath stringByAppendingPathComponent:file];
        }
    }

    // Now try to parse if found everything
    if ( stepsFilePath != nil && musicFilePath != nil )
    {

        // Parse very basic info from this file
        if ( m_idDelegate != nil )
        {
            [m_idDelegate startLoadingSong:songDirName];
        }

        TMLog(@"Music file path: %@", musicFilePath);

        // Make the files relative to the songs dir
        NSString *songsDir = [self getSongsPath:pathId];
        musicFilePath = [musicFilePath stringByReplacingOccurrencesOfString:songsDir withString:@""];
        stepsFilePath = [stepsFilePath stringByReplacingOccurrencesOfString:songsDir withString:@""];
        backgroundFilePath = [backgroundFilePath stringByReplacingOccurrencesOfString:songsDir withString:@""];

        TMSong *song = nil;

        if ( useCache && [m_pCatalogueCacheOld valueForKey:songDirName] != nil )
        {
            TMLog(@"Catalogue file has this file already!");
            song = [[m_pCatalogueCacheOld valueForKey:songDirName] retain];

            // Check hash
            NSString *songHash = [SongsDirectoryCache dirMD5:curPath];
            TMLog(@"GOT HASH: '%@'", songHash);
            TMLog(@"CACHED HASH IS: '%@'", song.m_sHash);

            if ( ![songHash isEqualToString:song.m_sHash] )
            {
                TMLog(@"Hash mismatch! Must reload!");
                [song release];
                song = [[TMSong alloc] initWithStepsFile:stepsFilePath andMusicFile:musicFilePath andBackgroundFile:backgroundFilePath andDir:songDirName fromSongsPathId:pathId];
                song.m_sHash = songHash;
                song.m_iSongsPath = pathId;
            }

            // Set as sync song if it is system or add to list otherwise
            if ( pathId == kSystemSongsPath )
            {
                [self setSyncSong:song];
            }
            else
            {
                [m_aAvailableSongs addObject:song];
            }

            // No matter where it comes from, cache or not, we need to save it to the new cache file
            [m_pCatalogueCacheNew setObject:song forKey:songDirName];

        }
        else
        {
           song = [[TMSong alloc] initWithStepsFile:stepsFilePath andMusicFile:musicFilePath andBackgroundFile:backgroundFilePath andDir:songDirName fromSongsPathId:pathId];

            // Calculate the hash and store it
            NSString *songHash = [SongsDirectoryCache dirMD5:curPath];
            TMLog(@"GOT HASH: '%@'", songHash);

            song.m_sHash = songHash;
            song.m_iSongsPath = pathId;

            // Set as sync song if it is system or add to list otherwise
            if ( pathId == kSystemSongsPath )
            {
                [self setSyncSong:song];
            }
            else
            {
                TMLog(@"Song ready to be added to list!!");
                [m_aAvailableSongs addObject:song];
            }

            // Add to new cache file
            [m_pCatalogueCacheNew setObject:song forKey:songDirName];
        }

        if ( m_idDelegate != nil )
        {
            [m_idDelegate  doneLoadingSong:song withPath:songDirName];
        }

        // Indicate that the catalogue is not empty anymore
        m_bCatalogueIsEmpty = NO;

        return YES;
    }
    else
    {
        if ( m_idDelegate != nil )
        {
            [m_idDelegate errorLoadingSong:songDirName withReason:@"\nSteps file or Music file not found."];
        }

        return NO;
    }
}

- (void)deleteSong:(NSString *)songDirName
{
    TMSong *foundSong = nil;

    for ( TMSong *song in m_aAvailableSongs )
    {

        // We can only delete user created songs
        if ( song.m_iSongsPath == kUserSongsPath
                && [song.m_sSongDirName isEqualToString:songDirName] )
        {
            foundSong = song;
            break;
        }
    }

    // Only delete found songs to prevent any harm
    if ( foundSong == nil )
    {
        return;
    }

    // Remove from current list
    [m_aAvailableSongs removeObject:foundSong];
    if ( [m_aAvailableSongs count] == 0 )
    {
        m_bCatalogueIsEmpty = YES;
    }

    // Update cache
    [m_pCatalogueCacheNew removeObjectForKey:songDirName];
    [self writeCatalogueCache];

    // Remove the directory on the FS
    NSError *err;
    [[NSFileManager defaultManager] removeItemAtPath:[[self getSongsPath:kUserSongsPath] stringByAppendingPathComponent:songDirName] error:&err];
}

- (NSMutableDictionary *)getCatalogueCache
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    if ( [paths count] > 0 )
    {
        NSString *dir = [paths objectAtIndex:0];
        NSString *catalogueName = [NSString stringWithFormat:kCatalogueFileName, TAPMANIA_CACHE_VERSION];
        NSString *catalogueFile = [[dir stringByAppendingPathComponent:catalogueName] retain];

        if ( [[NSFileManager defaultManager] fileExistsAtPath:catalogueFile] )
        {
            return [[NSMutableDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:catalogueFile]];
        }
    }

    TMLog(@"Catalogue cache is empty! Returning default empty cache instance...");
    return [[NSMutableDictionary alloc] init];
}

- (void)writeCatalogueCache
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    if ( [paths count] > 0 )
    {
        NSString *dir = [paths objectAtIndex:0];
        NSString *catalogueName = [NSString stringWithFormat:kCatalogueFileName, TAPMANIA_CACHE_VERSION];
        NSString *catalogueFile = [[dir stringByAppendingPathComponent:catalogueName] retain];

        TMLog(@"Write catalogue to: %@", catalogueFile);

        if ( YES == [NSKeyedArchiver archiveRootObject:m_pCatalogueCacheNew toFile:catalogueFile] )
        {
            TMLog(@"Successfully written the catalogue!");
        }
        else
        {
            TMLog(@"Too bad. Failed to write catalogue...");
        }
    }
}

- (void)setSyncSong:(TMSong *)song
{
    m_pSyncSong = song;
}

- (TMSong *)getSyncSong
{
    return m_pSyncSong;
}

+ (NSString *)fileMD5:(NSString *)path
{
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] fileAttributesAtPath:path traverseLink:YES];

    if ( fileAttributes == nil )
    {
        return @"Can't get file md5";
    }

    NSNumber *fileSize;
    NSString *result = @"";

    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);

    if ( fileSize = [fileAttributes objectForKey:NSFileSize] )
    {
        result = [result stringByAppendingString:[fileSize stringValue]];
    }

    NSString *name = [path lastPathComponent];
    result = [result stringByAppendingString:name];

    CC_MD5_Update(&md5, [result UTF8String], [result length]);

    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);

    NSString *s = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
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

+ (NSString *)dirMD5:(NSString *)path
{
    NSArray *dirContents = [[NSFileManager defaultManager] directoryContentsAtPath:path];

    if ( [dirContents count] == 0 )
    {
        return nil;
    }

    NSString *result = @"";
    int i;

    // Accumulate md5s of all files in the dir
    for ( i = 0; i < [dirContents count]; i++ )
    {
        NSString *md5 = [SongsDirectoryCache fileMD5:[path stringByAppendingPathComponent:[dirContents objectAtIndex:i]]];
        result = [result stringByAppendingString:md5];
    }

    // Create one md5 from the ruslt string
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    CC_MD5_Update(&md5, [result UTF8String], [result length]);

    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString *s = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
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

- (void)dealloc
{
    [m_SongsDirs release];
    [m_aAvailableSongs release];

    [super dealloc];
}


#pragma mark Singleton stuff

+ (SongsDirectoryCache *)sharedInstance
{
    @synchronized ( self )
    {
        if ( sharedSongsDirCacheDelegate == nil )
        {
            [[self alloc] init];
        }
    }
    return sharedSongsDirCacheDelegate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized ( self )
    {
        if ( sharedSongsDirCacheDelegate == nil )
        {
            sharedSongsDirCacheDelegate = [super allocWithZone:zone];
            return sharedSongsDirCacheDelegate;
        }
    }

    return nil;
}


- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release
{
    // NOTHING
}

- (id)autorelease
{
    return self;
}

@end
