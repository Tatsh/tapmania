//
//  $Id$
//  NewsDialog.h
//  TapMania
//
//  Created by Alex Kremer on 8/11/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMModalView.h"

@class Texture2D;

@interface NewsDialog : TMModalView
{
    Texture2D *m_pNewsText;

    /* Textures */
    Texture2D *t_DialogBG;
}

@end
