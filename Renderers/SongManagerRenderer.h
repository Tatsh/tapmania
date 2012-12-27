//
//  $Id$
//  SongManagerRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 06.08.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMScreen.h"

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
}

@end
