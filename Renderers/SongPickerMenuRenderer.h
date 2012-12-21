//
//  $Id$
//  SongPickerMenuRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 07.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMScreen.h"

@class SongPickerWheel, TMSound, TogglerItem, MenuItem, Texture2D;

@interface SongPickerMenuRenderer : TMScreen
{
    SongPickerWheel *m_pSongWheel;
    TogglerItem *m_pDifficultyToggler;
    TMSound *m_pPreviewMusic;

    /* Metrics and such */
    CGRect mt_ItemSong;
    int mt_ItemSongHalfHeight;

    CGRect mt_HighlightCenter;
    CGRect mt_Highlight;
    int mt_HighlightHalfHeight;

    // Resources
    Texture2D *t_Highlight;

    TMSound *sr_SelectSong;
}

@end
