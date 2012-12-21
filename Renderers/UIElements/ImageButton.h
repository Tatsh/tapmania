//
//  $Id$
//  ImageButton.h
//  TapMania
//
//  Created by Alex Kremer on 5/27/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMControl.h"

@class Texture2D;

@interface ImageButton : TMControl
{
    Texture2D *m_pTexture;
}

- (id)initWithTexture:(Texture2D *)tex andShape:(CGRect)shape;

@end
