//
//  Font.m
//  TapMania
//
//  Created by Alex Kremer on 25.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "Font.h"

#import "FontManager.h"
#import "FontCharmaps.h"
#import "TMFramedTexture.h"

@implementation Glyph
@synthesize m_pFontPage, m_nHorizAdvance, m_fWidth; 
@synthesize m_fHeight, m_fHorizShift;
@synthesize m_nTextureFrame;

- (id) initWithFrameId:(int)frameId {
	self = [super init];
	if(!self)
		return nil;

	m_nTextureFrame = frameId;
	
	return self;
}

@end


@implementation FontPage
@synthesize m_sPageName, m_nLineSpacing, m_fVertShift;
@synthesize m_aGlyphs, m_pCharToGlyphNo;
@synthesize m_pTexture;

- (id) initWithResource:(TMResource*)res {
	self = [super init];
	if(!self)
		return nil;
	
	m_pTextureResource = res;
	m_pTexture = (TMFramedTexture*)[m_pTextureResource resource];
	m_pCharToGlyphNo = [[NSMutableDictionary alloc] initWithCapacity:256];
	m_aGlyphs = [[NSMutableArray alloc] initWithCapacity:256];
	
	return self;
}

- (void) mapRange:(NSString*)charmap mapOffset:(int)offset glyphNo:(int)glyphNo count:(int)cnt {
	
	NSString* map = [[FontCharmaps sharedInstance] getCharMap:charmap];
	
	// for now - map all
	
	int i;
	if(cnt == -1)
		cnt = [map length]-1;
	
	for(i=0; i<cnt; ++i) {
		unichar c = [map characterAtIndex:i];
		
		NSNumber* num = [NSNumber numberWithInt:glyphNo];
		NSString* s = [NSString stringWithCharacters:&c length:1];
		
		[m_pCharToGlyphNo setObject:num forKey:s];
				
		TMLog(@"Mapped '%@' as '%d'", s, [num intValue]);
		
		glyphNo++;
	}	
}

- (void) setupGlyphsFromTexture:(TMFramedTexture*)tex andConfig:(NSDictionary*)config {
	
	int cols = [tex cols];
	int rows = [tex rows];
	
	float glyphWidth = [tex contentSize].width/cols;
	float glyphHeight = [tex contentSize].height/rows;
	
	int i,j;
	
	for(i=0; i<rows; ++i) {
		for(j=0; j<cols; ++j) {
			// TODO: use config to determine offsets
			// for now just rectangulate			
			Glyph* glyph = [[Glyph alloc] initWithFrameId:i*cols + j];			
			glyph.m_pFontPage = self;		
			glyph.m_fWidth = glyphWidth;
			glyph.m_fHeight = glyphHeight;
			
			[m_aGlyphs addObject:glyph];				
		}
	}
}

@end


@implementation Font

- (id) initWithName:(NSString*)name andConfig:(NSDictionary*)config {
	self = [super init];
	if(!self)
		return nil;
	
	m_sFontName = name;
	m_pConfig = [config retain];
	
	m_pCharToGlyph = [[NSMutableDictionary alloc] initWithCapacity:256];
	m_aPages = [[NSMutableArray alloc] initWithCapacity:6];
	
	// Configure font
	// TODO...
	
	return self;
}

// This does the real loading work
- (void) load {
	TMLog(@"Loading the %@ font...", m_sFontName);
	
	// Try to find a resource which has a matching name
	if(true) { // if we have no multiple pages
		TMResource* mainPage = [[[FontManager sharedInstance] textures] getResource:m_sFontName];
		if(mainPage) {
			TMLog(@"Found the texture resource!");

			// Here we must create a default page at least
			m_pDefaultPage = [[FontPage alloc] initWithResource:mainPage];			
			[m_aPages addObject:m_pDefaultPage];
			
			// Check how much frames it has
			TMFramedTexture* tex = (TMFramedTexture*)[mainPage resource];

			if(tex.totalFrames == 15) {
				TMLog(@"MAP deafult to numbers!");

				// Map the whole numbers charmap
				[m_pDefaultPage mapRange:@"numbers" mapOffset:0 glyphNo:0 count:-1];
			}
			
			// Now add real glyphs
			[m_pDefaultPage setupGlyphsFromTexture:tex andConfig:m_pConfig];
		}
	}
	
	// For every page we have - copy charmaps to the font object
	int page = 0;
	for(; page<[m_aPages count]; ++page) {
		TMLog(@"Cache page maps into our font maps...");
		FontPage* p = [m_aPages objectAtIndex:page];
		TMLog(@"Current page = %X", p);
		
		[self cacheMapsFromPage:p];
	}
}

- (void) cacheMapsFromPage:(FontPage*)page {
	int mappingId = 0;
	
	int totalMaps = [[page.maps allKeys] count];
	
	for(; mappingId<totalMaps; ++mappingId) {
		NSString* key = [[page.maps allKeys] objectAtIndex:mappingId];
		NSNumber* val = [page.maps objectForKey:key];
		
		Glyph* g = [page.glyphs objectAtIndex:[val intValue]];
		[m_pCharToGlyph setObject:g forKey:key];	
	}
}


- (void) drawText:(NSString*)str atPoint:(CGPoint)point {
	int curCharacter = 0;
	CGPoint curPoint = point;
	
	for(; curCharacter < [str length]; curCharacter++) {
		unichar c = [str characterAtIndex:curCharacter];
		NSString* mapTester = [NSString stringWithCharacters:&c length:1];
		
		Glyph* g = [m_pCharToGlyph objectForKey:mapTester];
		
		if(g) {
			glEnable(GL_BLEND);
			[[[g m_pFontPage] texture] drawFrame:[g m_nTextureFrame] atPoint:CGPointMake(curPoint.x+[g m_fWidth]/2, curPoint.y)];
			glDisable(GL_BLEND);
			
			curPoint = CGPointMake(curPoint.x+[g m_fWidth], point.y);
		} else {
			TMLog(@"Can't find mapping for '%@' char", mapTester);
		}
	}
}

- (void) drawAsImage {
	[[m_pDefaultPage texture] drawAtPoint:CGPointMake(320/2, 480/2)];
}

@end
