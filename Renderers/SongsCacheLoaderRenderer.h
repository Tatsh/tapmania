//
//  SongsCacheLoaderRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 22.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMLogicUpdater.h"
#import "TMSongsLoaderSupport.h"
#import "TMTransitionSupport.h"

#import "AbstractRenderer.h"

@class Texture2D;

@interface SongsCacheLoaderRenderer : AbstractRenderer <TMLogicUpdater, TMSongsLoaderSupport, TMTransitionSupport> {
	BOOL	m_bAllSongsLoaded;
	BOOL	m_bGlobalError;
	BOOL	m_bTextureShouldChange;
	
	NSString*	m_sCurrentMessage;
	Texture2D*	m_pCurrentTexture;
	
	NSThread* m_pThread;
	NSLock*   m_pLock;
}

@end
