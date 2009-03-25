//
//  Font.m
//  TapMania
//
//  Created by Alex Kremer on 25.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "Font.h"
#import "TMFramedTexture.h"

@implementation Glyph
@synthesize m_pFontPage, m_nHorizAdvance, m_fWidth; 
@synthesize m_fHeight, m_fHorizShift, m_oTextureRect;
@end


@implementation FontPage
@synthesize m_sPageName, m_nLineSpacing, m_fVertShift;
@synthesize m_aGlyphs; 

- (id) initWithResource:(TMResource*)res {
	self = [super init];
	if(!self)
		return nil;
	
	m_pTextureResource = res;
	m_pTexture = (TMFramedTexture*)[m_pTextureResource resource];
	
	return self;
}

@end


@implementation Font

@end
