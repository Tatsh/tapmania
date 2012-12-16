//
//  $Id$
//  Font.m
//  TapMania
//
//  Created by Alex Kremer on 25.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "Font.h"

#import "FontManager.h"
#import "FontCharmaps.h"
#import "FontCharAliases.h"
#import "Texture2D.h"
#import "TMSprite.h"
#import "Quad.h"

#include "rapidxml.hpp"
#include <vector>
#include <string>
#include <stdexcept>
#include <sstream>

namespace rx = rapidxml;

typedef rx::xml_attribute<char> xml_attr;
typedef rx::xml_node<char>      xml_node;
typedef rx::xml_document<char>  xml_doc;

template<typename T>
T get_attribute(xml_node* node, const std::string& attr_name)
{
    xml_attr* a = node->first_attribute(attr_name.c_str());
    if(a)
    {
        T v;
        std::stringstream ss;
        ss << a->value();
        if(ss >> v)
        {
            return v;
        }
        else
        {
            throw std::runtime_error("Can't convert attribute named " + attr_name + " to requested type.");
        }
    }
    else
    {
        throw std::runtime_error("Can't find attribute named " + attr_name + " in node.");
    }
}

@implementation Glyph
@synthesize m_nHorizAdvance, m_fWidth;
@synthesize m_fHeight, m_fHorizShift;
@synthesize m_fxOffset, m_fyOffset;
@synthesize m_id;
@synthesize m_oTextureRect;
@synthesize m_pFontPage;
@synthesize sprite = sprite_;

- (id) initWithId:(unichar)idx page:(FontPage*)page andRect:(CGRect)rect {
	self = [super init];
	if(!self)
		return nil;

    m_id = idx;
	m_nHorizAdvance = 1;
    m_pFontPage = page;
    sprite_ = [[TMSprite alloc] initWithTexture:page.texture andRect:rect];
	
	return self;
}

@end

@implementation FontPage
@synthesize m_nLineSpacing, m_fVertShift, m_fHeight, m_nExtraLeft, m_nExtraRight;
@synthesize font = font_;
@synthesize texture = texture_;

- (id) initWithResourceFile:(const std::string&)path id:(int)idx andFont:(Font*)fnt
{
	self = [super init];
	if(!self)
		return nil;

    self.font = fnt;
    page_id_ = idx;
    texture_path_ = path;
    
    UIImage *img = [UIImage imageWithContentsOfFile:[NSString stringWithUTF8String:texture_path_.c_str()]];
    self.texture = [[[Texture2D alloc] initWithImage:img] autorelease];
    assert(self.texture);
    
    return self;
}

- (void) addGlyph:(Glyph*) glyph
{
    glyphs_.push_back(glyph);
    glyph_widths_.push_back(glyph.m_fWidth);
    char_to_glyph_.insert(std::make_pair(glyph.m_id, glyph));
}

- (std::vector<Glyph*>) getGlyphs
{
    return glyphs_;
}

@end


@implementation Font

@synthesize m_pDefaultPage, m_aPages, m_pCharToGlyph, m_pDefaultGlyph;
@synthesize baseline = baseline_;
@synthesize size = size_;
@synthesize line_height = line_height_;

- (id) initWithName:(NSString*)name andFile:(NSString*)filePath {
	self = [super init];
	if(!self)
		return nil;
	
	m_sFontName = name;
    m_sFontPath = [filePath stringByDeletingLastPathComponent];
	m_bIsLoaded = NO;	
	
	m_bMultipage = NO;
	m_pCharToGlyph = [[NSMutableDictionary alloc] initWithCapacity:256];
	m_aPages = [[NSMutableArray alloc] initWithCapacity:6];

    [self parseFontXML:filePath];
    
	return self;
}

- (void) parseFontXML:(NSString*)filePath {
    TMLog(@"Loading font from '%@'", filePath);
    
    xml_doc doc;
    NSData* nsd = [NSData dataWithContentsOfFile:filePath];
    if(!nsd) {
        TMLog(@"Couldn't create NSData from font file at '%@'", filePath);
        throw std::runtime_error("Couldn't open NSData font file :-(");
    }
    
    std::string data((char*)[nsd bytes],
                     (char*)[nsd bytes]+[nsd length]);
    data.resize([nsd length]);
    
    try
    {
        doc.parse<0>(&(data.at(0)));
    }
    catch( rx::parse_error& ex )
    {
        TMLog(@"Failed to parse: %s", ex.what());
        throw std::runtime_error( std::string("RapidXML parse error: ") + ex.what() );
    }
            
    xml_node *root = doc.first_node( "font" );
    if( !root )
    {
        throw std::runtime_error("Not a valid font xml. must begin with <font> root element.");
    }
    
    for(xml_node* node = root->first_node(); node; node = node->next_sibling())
    {
        if(node->type() == rx::node_element)
        {
            if(node->name() == std::string("info"))
            {
                size_ = get_attribute<int>(node, "size");
                int stretchH = get_attribute<int>(node, "stretchH");
                
                TMLog(@"Found stretchH %d", stretchH);
            }
            else if(node->name() == std::string("common"))
            {                
                line_height_ = get_attribute<int>(node, "lineHeight");
                baseline_ = get_attribute<int>(node, "base");
//                int scaleW = get_attribute<int>(node, "scaleW");
//                int scaleH = get_attribute<int>(node, "scaleH");
//                int pages = get_attribute<int>(node, "pages");
            }
            else if(node->name() == std::string("pages"))
            {
                for(xml_node* n = node->first_node(); n; n = n->next_sibling())
                {
                    if(n->type() == rx::node_element)
                    {
                        // each page has id, file
                        if(n->name() == std::string("page"))
                        {
                            std::string pngFile = get_attribute<std::string>(n, "file");
                            pngFile = std::string(m_sFontPath.UTF8String) + "/" + pngFile;
                            
                            int idx = get_attribute<int>(n, "id");
                            
                            TMLog(@"Found page [%d] %s", idx, pngFile.c_str());
                            [m_aPages insertObject:[[[FontPage alloc]
                                                     initWithResourceFile:pngFile
                                                     id:idx andFont:self] autorelease]
                                           atIndex:idx];
                        }
                    }
                }
            }
            else if(node->name() == std::string("chars"))
            {
                for(xml_node* n = node->first_node(); n; n = n->next_sibling())
                {
                    if(n->type() == rx::node_element)
                    {
                        // id (int), x,y,width,height
                        // xoffset, yoffset, xadvance, page, letter
                        if(n->name() == std::string("char"))
                        {
                            CGRect r;
                            r.origin.x = get_attribute<int>(n, "x");
                            r.origin.y = get_attribute<int>(n, "y");
                            r.size.width = get_attribute<int>(n, "width");
                            r.size.height = get_attribute<int>(n, "height");

                            Glyph *glyph = [[[Glyph alloc] initWithId:get_attribute<unichar>(n, "id")
                                page:[m_aPages objectAtIndex:get_attribute<int>(n, "page")]
                                    andRect:r] autorelease];

                            glyph.m_fxOffset = get_attribute<float>(n, "xoffset");
                            glyph.m_fyOffset = get_attribute<float>(n, "yoffset");
                            glyph.m_nHorizAdvance = get_attribute<int>(n, "xadvance");
                            
                            glyph.m_fWidth = r.size.width;
                            glyph.m_fHeight = r.size.height;
                            
                            [glyph.m_pFontPage addGlyph:glyph];
                            
                            TMLog(@"Added '%C' to font", glyph.m_id);
                        }
                    }
                }
            }
            else if(node->name() == std::string("kernings"))
            {
                TMLog(@"Found kernings");
                for(xml_node* n = node->first_node(); n; n = n->next_sibling())
                {
                    if(n->type() == rx::node_element)
                    {
                        //  <kerning first="121" second="44" amount="-2"/>
                        if(n->name() == std::string("kerning"))
                        {
                            TMLog(@"Found kerning!");
                            [self addKerningAmount:get_attribute<int>(n, "amount")
                                      forFirstChar:get_attribute<unichar>(n, "first")
                                     andSecondChar:get_attribute<unichar>(n, "second")];
                        }
                    }
                }
            }
        }
    }
}

// This does the real loading work
- (void) load {
	if(m_bIsLoaded) {
		TMLog(@"Attempt to load %@ font which is already loaded. break.", m_sFontName);
		return;
	}
	
	TMLog(@"Loading the %@ font...", m_sFontName);
    for(int i=0; i<[m_aPages count]; ++i)
    {
        TMLog(@"Cache maps from page %d", i);
        [self cacheMapsFromPage:[m_aPages objectAtIndex:i]];
    }
	
	m_bIsLoaded = YES;
}

- (void) addKerningAmount:(int)amount forFirstChar:(unichar)first andSecondChar:(unichar)second
{
    kern_map::iterator it = kernings_map_.find(first);
    if(it != kernings_map_.end())
    {
        it->second.insert(std::make_pair(second, amount));
        TMLog(@"KERNING Inserting to existing map for %C -> %C == %d", first, second, amount);
    }
    else
    {
        std::map<unichar, int> mp;
        mp.insert(std::make_pair(second, amount));
        kernings_map_.insert(std::make_pair(first, mp));
        TMLog(@"KERNING Inserting to NEW map for %C -> %C == %d", first, second, amount);
    }
}

- (int) getKerningAmountFor:(unichar)first andSecondChar:(unichar)second
{
    kern_map::iterator it = kernings_map_.find(first);
    if(it != kernings_map_.end())
    {
        std::map<unichar, int>::iterator jt = it->second.find(second);
        if(jt != it->second.end())
        {
            TMLog(@"Found kerning for %C and %C == %d", first, second, jt->second);
            return jt->second;
        }
    }
    
    return 0;
}

- (void) mergeFont:(Font*)other {
	if(m_pDefaultPage == nil) {
		// Steal the page pointer
		m_pDefaultPage = other.defaultPage;
	}
	
	// Cache all char to glyphs
	[m_pCharToGlyph setValuesForKeysWithDictionary:other.maps];
	
	// Copy all pages
	[m_aPages addObjectsFromArray:other.pages];
	
	// Clear the imported font
	[[other pages] removeAllObjects];
}

- (void) cacheMapsFromPage:(FontPage*)page {
    std::vector<Glyph*> gl = [page getGlyphs];
    
    for(int i=0; i<gl.size(); ++i)
    {
        Glyph* g = gl.at(i);
        TMLog(@"Add char '%C' to cache", g.m_id);
        [m_pCharToGlyph setObject:g forKey:[NSNumber numberWithUnsignedShort:g.m_id]];
    }
}

- (Glyph*) getGlyph:(unichar)inChar {
    
	Glyph* g = [m_pCharToGlyph objectForKey:[NSNumber numberWithUnsignedShort:inChar]];
	Font* df = [[FontManager sharedInstance] defaultFont];
	
	// If not found here - use default font
	if(!g && self != df) {
		g = [df getGlyph:inChar];
	}

    if(!g) {
        g = [m_pCharToGlyph objectForKey:[NSNumber numberWithUnsignedShort:(unichar)'?']];
    }
	
	// If no default glyph - error
	if(!g) {
		// ERROR!
		NSException *ex = [NSException exceptionWithName:@"DefaultGlyphMissing" 
												  reason:[NSString stringWithFormat:@"Font '%@' missing default glyph", m_sFontName] userInfo:nil];
		@throw ex;			
	}
	
	return g;
}

- (CGSize) getStringWidthAndHeight:(NSString*)str {
	float width = 0.0f;
	float totalWidth = 0.0f;
	
	int i;
	unichar c;	// Last char
	int len = [str length];
	
	for(i=0; i<len; ++i) {
		c = [str characterAtIndex:i];
	
        Glyph* g = [self getGlyph:c];
		if(i == 0) {
			width += [[g m_pFontPage] m_nExtraLeft];
		} else if(i == len-1) {
			width += [[g m_pFontPage] m_nExtraRight];
		}
		
		width += [g m_nHorizAdvance];
        if(len > 1 && i < len-1)
        {
            width += [self getKerningAmountFor:c andSecondChar:[str characterAtIndex:i+1]];
        }
	}
		
	totalWidth = fmaxf(totalWidth, width);	
	
    // HACK: give some extra space just in case :-)
	return CGSizeMake(totalWidth + 4, self.line_height);
}

- (Quad*) createQuadFromText:(NSString*)str {
//	int lineNum = 1;
	float curPoint = 0.0f;
	CGSize strSize = [self getStringWidthAndHeight:str];
	
	Quad* result = [[Quad alloc] initWithWidth:strSize.width andHeight:strSize.height];
	int len = [str length];
	
	for(int curCharacter=0; curCharacter < len; ++curCharacter) {
		unichar c = [str characterAtIndex:curCharacter];
		Glyph* g = [self getGlyph:c];

        if(curCharacter == 0) {
			curPoint += [g.m_pFontPage m_nExtraLeft] + 2;
            
            if(g.m_fxOffset < 0)
            {
                curPoint += fabsf(g.m_fxOffset);
            }
		}
		
        curPoint += g.m_nHorizAdvance/2.0f;
		
        if(len > 1 && curCharacter < len-1)
        {
            curPoint += [self getKerningAmountFor:c andSecondChar:[str characterAtIndex:curCharacter+1]];
        }
        
        float y = (g.m_pFontPage.font.line_height - g.m_fHeight)/2.0f;
        y -= g.m_fyOffset;
        float x = curPoint + g.m_fxOffset;
        
        [result renderSprite:g.sprite atPoint:CGPointMake(x, y + (strSize.height/2.0f))];
		
		curPoint += g.m_nHorizAdvance/2.0f;
	}
	
	return result;
}

@end
