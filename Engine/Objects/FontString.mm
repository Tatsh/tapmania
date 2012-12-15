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
#import "TMSprite.h"

@implementation FontString
@synthesize contentSize=m_oSize;
@synthesize alignment=m_Align;

-(id) initWithFont:(NSString*)font andText:(NSString*)str {
	self = [super init];
	if(!self) return nil;
	
	m_pFont = [[FontManager sharedInstance] getFont:font];
    if(!m_pFont)
    {
        m_pFont = [[FontManager sharedInstance] defaultFont];
    }
    
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
    
	int len = [str length];
    
	for(int curCharacter=0; curCharacter < len; ++curCharacter) {
		unichar c = [str characterAtIndex:curCharacter];
		Glyph* g = [m_pFont getGlyph:c];
		
		if(curCharacter == 0) {
			curPoint += [[g m_pFontPage] m_nExtraLeft];	
		} 
		
        curPoint += g.m_nHorizAdvance/2.0f;
        
        if(len > 1 && curCharacter < len-1)
        {
            curPoint += [m_pFont getKerningAmountFor:c andSecondChar:[str characterAtIndex:curCharacter+1]];
        }
        
        float y = (g.m_pFontPage.font.line_height - g.m_fHeight)/2.0f;
        y -= g.m_fyOffset;
        float x = curPoint + g.m_fxOffset;

		m_Glyphs->push_back( GlyphInfo(g, x, y) );
		curPoint += g.m_nHorizAdvance/2.0f;
		
		if(curCharacter == len-1) {
			curPoint += [[g m_pFontPage] m_nExtraRight];		
		}
		
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
        glPushMatrix();
        glTranslatef(point.x+it->m_xOffset, point.y+it->m_yOffset, 0.0f);        
        [g.sprite draw];
        glPopMatrix();
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

        glPushMatrix();
        glTranslatef(it->m_xOffset, it->m_yOffset, 0.0f);
        [g.sprite draw];
        glPopMatrix();
	}
	
	glPopMatrix();
}


@end
