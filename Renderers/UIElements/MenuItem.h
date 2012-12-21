//
//  $Id$
//  MenuItem.h
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "Label.h"

@class TMFramedTexture, Texture2D;

@interface MenuItem : Label
{
    TMFramedTexture *m_pTexture;
    BOOL m_bShouldLock;
}

- (id)initWithTitle:(NSString *)title andShape:(CGRect)shape;

@end
