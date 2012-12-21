//
//  $Id$
//  SongOptionsDialogRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 12.09.10.
//  Copyright 2010 Godexsoft. All rights reserved.
//

#import "TMModalView.h"

@class TogglerItem;

@interface SongOptionsDialogRenderer : TMModalView
{
    TogglerItem *m_pNoteSkinToggler;
    TogglerItem *m_pSpeedToggler;
    TogglerItem *m_pReceptorModsToggler, *m_pNoteModsToggler;
}

@end
