//
//  FontString.mm
//  TapMania
//
//  Created by Alex Kremer on 21.01.10.
//  Copyright 2010 Godexsoft. All rights reserved.
//
//  $Id$

#import "FontString.h"
#import "FontManager.h"
#import "TMFramedTexture.h"

@implementation FontString
@synthesize contentSize=m_oSize;
@synthesize alignment=m_Align;

-(id) initWithFont:(NSString*)font andText:(NSString*)str {
	self = [super init];
	if(!self) return nil;
	
	m_pFont = [[FontManager sharedInstance] getFont:font];
	m_Glyphs = new GlyphInfoVec();
	
	// Construct glyphs from string
	[self updateText:str];
	
	return self;
}

-(void) updateText:(NSString*)str {
	// Clear old
	m_Glyphs->clear();	
	m_oSize.width = m_oSize.height = 0.0f;
	
	// Get glyph by glyph
	float curPoint = 0.0f;
		
	for(int curCharacter=0; curCharacter < [str length]; ++curCharacter) {
		unichar c = [str characterAtIndex:curCharacter];

		NSString* mapTester = [NSString stringWithFormat:@"%C", c];
		Glyph* g = [m_pFont getGlyph:mapTester];		
		
		curPoint += [[g m_pFontPage] m_nExtraLeft] + [g m_fWidth]/2;
		m_Glyphs->push_back( GlyphInfo(g, curPoint, 0) );
		curPoint += [g m_fWidth]/2 + [g m_nHorizAdvance] + [[g m_pFontPage] m_nExtraRight];
		
		m_oSize.height = fmaxf(m_oSize.height, [g m_fHeight]);
	}	
	
	m_oSize.width = curPoint;
}

-(void) dealloc {
	delete m_Glyphs;
	[super dealloc];
}

// Drawing
- (void) drawAtPoint:(CGPoint)point {
	if(m_Glyphs->empty()) return;
	
	if(m_Align == UITextAlignmentCenter) {
		point.x -= m_oSize.width/2;
	} else if(m_Align == UITextAlignmentRight) {
		point.x -= m_oSize.width;
	}
	
	for(GlyphInfoVec::iterator it = m_Glyphs->begin(); it!=m_Glyphs->end(); ++it) {
		Glyph* g = it->m_pGlyph;
		[[[g m_pFontPage] texture] drawFrame:[g m_nTextureFrame] atPoint:CGPointMake(point.x+it->m_xOffset, point.y+it->m_yOffset)];
	}
}

- (void) drawInRect:(CGRect)rect {
	if(m_Glyphs->empty()) return;
	
	glPushMatrix();
	glLoadIdentity();
	
	float ratio = rect.size.width/m_oSize.width;
	glScalef(ratio, 1.0, 1.0);
	glTranslatef(rect.origin.x/ratio, rect.origin.y, 0.0f);
	
	for(GlyphInfoVec::iterator it = m_Glyphs->begin(); it!=m_Glyphs->end(); ++it) {
		Glyph* g = it->m_pGlyph;
		[[[g m_pFontPage] texture] drawFrame:[g m_nTextureFrame] atPoint:CGPointMake(it->m_xOffset, it->m_yOffset)];
	}
	
	glPopMatrix();
}


@end
