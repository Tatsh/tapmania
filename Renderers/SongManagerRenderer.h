//
//  $Id$
//  SongManagerRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 06.08.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMScreen.h"

@class Texture2D;

typedef enum
{
    kSongManagerAction_None = 0,
    kSongManagerAction_Running,
    kSongManagerAction_Exit,
    kNumSongManagerActions
} TMSongManagerActions;

@interface SongManagerRenderer : TMScreen
{
    TMSongManagerActions m_nAction;

    Texture2D *m_pServerUrl;

    /* Metrics and such */
    CGPoint mt_UrlPosition;
}

@end
