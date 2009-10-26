//
//  MenuItem.h
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "Label.h"

@class TMFramedTexture, Texture2D, TMSound;

@interface MenuItem : Label {
	TMFramedTexture*	m_pTexture;
	
	/* Sound effect */
	TMSound*	sr_MenuButtonEffect;
}

- (id) initWithTitle:(NSString*)title andShape:(CGRect) shape;

@end
