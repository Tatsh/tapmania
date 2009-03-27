//
//  Font.h
//  TapMania
//
//  Created by Alex Kremer on 25.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMResource;
@class TMFramedTexture;
@class FontPage;

/*
 * A glyph. 
 * Contains one character map from a font page.
 */
@interface Glyph : NSObject {
	FontPage* m_pFontPage;
	
	int m_nHorizAdvance;
	float m_fWidth, m_fHeight;
	float m_fHorizShift;
	
	CGRect m_oTextureRect;
	int		m_nTextureFrame;
}

- (id) initWithFrameId:(int)frameId;

@property(retain, nonatomic) FontPage* m_pFontPage;
@property(assign) int m_nHorizAdvance;
@property(assign) float m_fWidth;
@property(assign) float m_fHeight;
@property(assign) float m_fHorizShift;
@property(assign, readonly) int m_nTextureFrame;

@end

/*
 * A font page.
 * This maps to one graphical resource (texture)
 */
@interface FontPage : NSObject {
	NSString*	m_sPageName;
	
	int			m_nLineSpacing;
	float		m_fVertShift;
	
	TMResource*			m_pTextureResource;
	TMFramedTexture*	m_pTexture;	// The texture extracted from the resource
	
	NSMutableArray*			m_aGlyphs;
	NSMutableDictionary*	m_pCharToGlyphNo;		// Contains direct mappings
	NSMutableDictionary*	m_pGlyphWidths;	// If missing - use texture frame width
}

@property(retain, nonatomic) NSString* m_sPageName;
@property(assign) int m_nLineSpacing;
@property(assign) float m_fVertShift;

@property(retain, nonatomic, readonly, getter=glyphs) NSMutableArray* m_aGlyphs; 
@property(retain, nonatomic, readonly, getter=maps) NSMutableDictionary* m_pCharToGlyphNo; 

@property(retain, nonatomic, readonly, getter=texture) TMFramedTexture* m_pTexture;

- (id) initWithResource:(TMResource*)res andSettings:(NSArray*)settings;

- (void) mapRange:(NSString*)charmap mapOffset:(int)offset glyphNo:(int)glyphNo count:(int)cnt;
- (void) setupGlyphsFromTexture:(TMFramedTexture*)tex andConfig:(NSDictionary*)config;

@end

/* 
 * A final font.
 * The font is constructed from font pages.
 */
@interface Font : NSObject {
	NSString*			m_sFontName;
	BOOL				m_bMultipage;	// True if has multiple pages
	
	NSDictionary*		m_pConfig;
	NSMutableArray*		m_aPages;
	FontPage*			m_pDefaultPage;
	
	NSMutableDictionary*		m_pCharToGlyph;		// Contains direct mappings to Glyph objects
}

@property(retain, nonatomic, readonly, getter=maps) NSMutableDictionary* m_pCharToGlyph; 

- (id) initWithName:(NSString*) name andConfig:(NSDictionary*)config;
- (void) load;
- (void) cacheMapsFromPage:(FontPage*)page;

- (void) drawText:(NSString*)str atPoint:(CGPoint)point;

@end
