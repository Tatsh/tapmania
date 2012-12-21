//
//  $Id$
//  Font.h
//  TapMania
//
//  Created by Alex Kremer on 25.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <string>
#include <vector>
#include <map>

@class TMResource;
@class Texture2D, Quad;
@class FontPage, Font;
@class TMSprite;

const static unichar DEFAULT_GLYPH = 0xF8FF;
const static unichar INVALID_CHAR = 0xFFFD;

typedef std::map<unichar, std::map<unichar, int> > kern_map;

/*
 * A glyph. 
 * Contains one character map from a font page.
 */
@interface Glyph : NSObject
{
    FontPage *m_pFontPage; // page

    unichar m_id; // character id in unicode table

    int m_nHorizAdvance; // xadvance
    float m_fWidth, m_fHeight; // ??
    float m_fxOffset, m_fyOffset; // xoffset, yoffset
    float m_fHorizShift; // dunno what

    CGRect m_oTextureRect; // x,y,width,height
    TMSprite *sprite_;
}

- (id)initWithId:(unichar)idx page:(FontPage *)page andRect:(CGRect)rect;

@property(retain, nonatomic) FontPage *m_pFontPage;
@property(retain, nonatomic) TMSprite *sprite;
@property(assign) unichar m_id;
@property(assign) int m_nHorizAdvance;
@property(assign) float m_fWidth;
@property(assign) float m_fHeight;
@property(assign) float m_fxOffset;
@property(assign) float m_fyOffset;
@property(assign) float m_fHorizShift;
@property(assign) CGRect m_oTextureRect;

@end

/*
 * A font page.
 * This maps to one graphical resource (texture)
 */
@interface FontPage : NSObject
{
    int m_nLineSpacing, m_nExtraLeft, m_nExtraRight;
    float m_fVertShift;
    float m_fHeight;

    int page_id_;
    std::string texture_path_;
    std::map<UniChar, Glyph *> char_to_glyph_;
    std::vector<Glyph *> glyphs_;
    std::vector<float> glyph_widths_;

    Font *font_;
    Texture2D *texture_;
}

@property(assign) int m_nLineSpacing;
@property(assign) int m_nExtraLeft;
@property(assign) int m_nExtraRight;
@property(assign) float m_fVertShift;
@property(assign) float m_fHeight;
@property(retain, nonatomic) Font *font;
@property(retain, nonatomic) Texture2D *texture;

- (id)initWithResourceFile:(const std::string&)path id:(int)idx andFont:(Font *)fnt;

- (void)addGlyph:(Glyph *)glyph;

@end

/* 
 * A final font.
 * The font is constructed from font pages.
 */
@interface Font : NSObject
{
    NSString *m_sFontName;
    NSString *m_sFontPath;

    BOOL m_bMultipage;    // True if has multiple pages
    BOOL m_bIsLoaded;    // True if this font is already complete and loaded

    int size_;
    int line_height_;
    int baseline_;

    NSMutableArray *m_aPages;
    FontPage *m_pDefaultPage;

    kern_map kernings_map_;

    NSMutableDictionary *m_pCharToGlyph;        // Contains direct mappings to Glyph objects
    Glyph *m_pDefaultGlyph;
}

@property(retain, nonatomic, readonly, getter=maps) NSMutableDictionary *m_pCharToGlyph;

@property(retain, nonatomic, readonly, getter=pages) NSMutableArray *m_aPages;
@property(retain, nonatomic, readonly, getter=defaultPage) FontPage *m_pDefaultPage;
@property(retain, nonatomic, readonly, getter=defaultGlyph) Glyph *m_pDefaultGlyph;
@property(assign, readonly) int baseline;
@property(assign, readonly) int line_height;
@property(assign, readonly) int size;

- (id)initWithName:(NSString *)name andFile:(NSString *)filePath;

- (void)parseFontXML:(NSString *)filePath;

- (void)load;

- (void)cacheMapsFromPage:(FontPage *)page;

- (void)addKerningAmount:(int)amount forFirstChar:(unichar)first andSecondChar:(unichar)second;

- (int)getKerningAmountFor:(unichar)first andSecondChar:(unichar)second;

- (CGSize)getStringWidthAndHeight:(NSString *)str;

- (Glyph *)getGlyph:(unichar)inChar;

- (Quad *)createQuadFromText:(NSString *)str;

@end
