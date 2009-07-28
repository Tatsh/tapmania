//
//  SongsDirectoryCache.h
//  TapMania
//
//  Created by Alex Kremer on 07.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMSongsLoaderSupport.h"

#define kCatalogueFileName @"TapManiaCatalogue.plist"
@class TMSong;

@interface SongsDirectoryCache : NSObject {
	NSString*				m_sSongsDir;		// The path to 'Songs' directory
	NSMutableArray*			m_aAvailableSongs;	// This holds a list of all songs which are available in the 'Songs' dir
	
	NSMutableDictionary*	m_pCatalogueCache;
	BOOL					m_bCatalogueIsEmpty;
	
	id						m_idDelegate;	// TMSongLoaderSupport delegate
}

@property (assign, setter=delegate:, getter=delegate) id<TMSongsLoaderSupport> m_idDelegate;
@property (assign, getter=catalogueIsEmpty) BOOL m_bCatalogueIsEmpty;

- (void) cacheSongs;
- (NSArray*) getSongList;
- (NSString*) getSongsPath;

- (TMSong*) getSongNextTo:(TMSong*)song;
- (TMSong*) getSongPrevFrom:(TMSong*)song;

- (void) deleteSong:(NSString*)songDirName;
- (void) addSongsFrom:(NSString*)rootDir;

+ (SongsDirectoryCache *)sharedInstance;

@end
