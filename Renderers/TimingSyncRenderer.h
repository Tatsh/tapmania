//
//  $Id$
//  TimingSyncRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 22.12.12.
//  Copyright 2008-2012 Godexsoft. All rights reserved.
//

#import "SongPlayRenderer.h"

@class MenuItem;
@class FontString;

@interface TimingSyncRenderer : SongPlayRenderer
{
    MenuItem *m_pResetButton;
    FontString *m_pOffsetLabel;
    CGPoint mt_OffsetLabelLocation;
}

@end
