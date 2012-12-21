//
//  $Id$
//  SongsCacheLoaderRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 22.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "TMScreen.h"
#import "TMSongsLoaderSupport.h"

@class FontString, TMSound;

@interface SongsCacheLoaderRenderer : TMScreen <TMSongsLoaderSupport>
{
    BOOL m_bAllSongsLoaded;
    BOOL m_bTransitionIsDone;
    BOOL m_bGlobalError;
    BOOL m_bTextureShouldChange;

    NSString *m_sCurrentMessage;
    FontString *m_pCurrentStr;

    NSThread *m_pThread;
    NSLock *m_pLock;

    // Resources
    TMSound *sr_BG;

    // Metrics
    CGPoint mt_Message;
}

@end
