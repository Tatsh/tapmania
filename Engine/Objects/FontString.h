//
//  FontString.h
//  TapMania
//
//  Created by Alex Kremer on 21.01.10.
//  Copyright 2010 Godexsoft. All rights reserved.
//
//  $Id$

#import "Font.h"

// The CPP part of this class
#ifdef __cplusplus

#include <vector>	

struct GlyphInfo
{
    Glyph *m_pGlyph;    // A direct pointer to the glyph

    float m_xOffset;    // The relative offset on the screen to render this glyph
    float m_yOffset;

    // Constructor
    GlyphInfo(Glyph *ptr, float xOffset, float yOffset)
    : m_pGlyph(ptr)
    , m_xOffset(xOffset)
    , m_yOffset(yOffset)
    {
    }
};

typedef std::vector<GlyphInfo> GlyphInfoVec;

#endif

@interface FontString : NSObject
{
    Font *m_pFont;            // The font used to render this string
    CGSize m_oSize;            // Original size of the string using the given font
    UITextAlignment m_Align;

#ifdef __cplusplus
    GlyphInfoVec *m_Glyphs;    // A collection of glyph pointers plus offset information
#endif
}

@property(assign, readonly) CGSize contentSize;
@property(assign) UITextAlignment alignment;

// The constructor
- (id)initWithFont:(NSString *)font andText:(NSString *)str;

// Updating the text
- (void)updateText:(NSString *)str;

// Drawing
- (void)drawAtPoint:(CGPoint)point;

- (void)drawInRect:(CGRect)rect;

@end
