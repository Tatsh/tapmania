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
	NSString*			songsDir;		// The path to 'Songs' directory
	NSMutableArray*		availableSongs;	// This holds a list of all songs which are available in the 'Songs' dir
	
	id					delegate;	// TMSongLoaderSupport delegate
}

@property (assign) id<TMSongsLoaderSupport> delegate;

- (void) cacheSongs;
- (NSArray*) getSongList;
- (NSString*) getSongsPath;

+ (SongsDirectoryCache *)sharedInstance;

@end
