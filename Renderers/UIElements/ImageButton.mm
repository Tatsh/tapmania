//
//  ImageButton.m
//  TapMania
//
//  Created by Alex Kremer on 5/27/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "ImageButton.h"
#import "TMFramedTexture.h"
#import "ThemeManager.h"
#import "Texture2D.h"
#import "TapMania.h"
#import "EAGLView.h"

@implementation ImageButton

- (id) initWithTexture:(Texture2D*) tex andShape:(CGRect) shape {
	self = [super initWithShape:shape];
	if(!self) 
		return nil;

	m_pTexture = tex;
	
	return self;
}

/* TMRenderable stuff */
- (void) render:(float)fDelta {
	glEnable(GL_BLEND);
	[m_pTexture drawInRect:m_rShape];
	glDisable(GL_BLEND);
}

@end
