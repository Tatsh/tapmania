//
//  $Id$
//  SongsDirectoryCache.h
//  TapMania
//
//  Created by Alex Kremer on 07.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMSongsLoaderSupport.h"

#define kCatalogueFileName @"TapManiaCatalogue_%s.plist"
@class TMSong;

typedef enum
{
    kInvalidSongsPath = 0,
    kBundleSongsPath,    // The path to bundled 'Songs' directory
    kUserSongsPath,        // The path to bundled 'Songs' directory
    kSystemSongsPath,    // Path to bundled system songs directory
    kNumSongsPaths
} TMSongsPath;


@interface SongsDirectoryCache : NSObject
{
    NSMutableDictionary *m_SongsDirs;
    NSMutableArray *m_aAvailableSongs;    // This holds a list of all songs which are available in the 'Songs' dir

    NSMutableDictionary *m_pCatalogueCacheOld;
    NSMutableDictionary *m_pCatalogueCacheNew;
    BOOL m_bCatalogueIsEmpty;

    TMSong* m_pSyncSong;

    id m_idDelegate;    // TMSongLoaderSupport delegate
}

@property(assign, setter=delegate:, getter=delegate) id <TMSongsLoaderSupport> m_idDelegate;
@property(assign, getter=catalogueIsEmpty) BOOL m_bCatalogueIsEmpty;

- (void)cacheSongs;

- (NSArray *)getSongList;

- (NSString *)getSongsPath:(TMSongsPath)pathId;

- (int)songIndex:(NSString *)hash;

- (TMSong *)getSongNextTo:(TMSong *)song;

- (TMSong *)getSongPrevFrom:(TMSong *)song;

- (void)deleteSong:(NSString *)songDirName;

- (void)addSongsFrom:(NSString *)rootDir;

+ (SongsDirectoryCache *)sharedInstance;

- (TMSong *)getSyncSong;

@end
