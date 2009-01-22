//
//  SongsCacheLoaderRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 22.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AbstractRenderer.h"
#import "TMLogicUpdater.h"
#import "TMSongsLoaderSupport.h"
#import "TMTransitionSupport.h"
#import "Texture2D.h"

@interface SongsCacheLoaderRenderer : AbstractRenderer <TMLogicUpdater, TMSongsLoaderSupport, TMTransitionSupport> {
	BOOL	_allSongsLoaded;
	BOOL	_globalError;
	BOOL	_textureShouldChange;
	
	NSString* _currentMessage;
	Texture2D* _currentTexture;
	
	NSThread* _thread;
	NSLock*   _lock;
}

@end
