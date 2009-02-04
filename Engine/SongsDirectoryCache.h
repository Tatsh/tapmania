//
//  SongsDirectoryCache.h
//  TapMania
//
//  Created by Alex Kremer on 07.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMSongsLoaderSupport.h"

@interface SongsDirectoryCache : NSObject {
	NSString*			m_sSongsDir;		// The path to 'Songs' directory
	NSMutableArray*		m_aAvailableSongs;	// This holds a list of all songs which are available in the 'Songs' dir
	
	id					m_idDelegate;	// TMSongLoaderSupport delegate
}

@property (assign, setter=delegate:, getter=delegate) id<TMSongsLoaderSupport> m_idDelegate;

- (void) cacheSongs;
- (NSArray*) getSongList;
- (NSString*) getSongsPath;

+ (SongsDirectoryCache *)sharedInstance;

@end
