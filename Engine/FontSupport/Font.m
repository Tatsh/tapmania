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

@interface FontPage (Private)
- (void) doRange:(NSString*)setting;
- (void) doLine:(NSString*)setting;
@end

@implementation FontPage
@synthesize m_sPageName, m_nLineSpacing, m_fVertShift;
@synthesize m_aGlyphs, m_pCharToGlyphNo;
@synthesize m_pTexture;

- (id) initWithResource:(TMResource*)res andSettings:(NSArray*)settings {
	self = [super init];
	if(!self)
		return nil;
	
	m_pTextureResource = res;
	m_pTexture = (TMFramedTexture*)[m_pTextureResource resource];
	m_pCharToGlyphNo = [[NSMutableDictionary alloc] initWithCapacity:256];
	m_pGlyphWidths = [[NSMutableDictionary alloc] initWithCapacity:256];
	m_aGlyphs = [[NSMutableArray alloc] initWithCapacity:256];
	
	// Parse settings...
	if(settings) {		
		int i;
		for(i=0; i<[settings count]; ++i) {			
			NSString* setting = [settings objectAtIndex:i];
			
			// range name=...
			if([[setting lowercaseString] hasPrefix:@"range"]) {
				TMLog(@"Got range!!");
				
				[self doRange:setting];				
			}			
			// line id=...
			else if([[setting lowercaseString] hasPrefix:@"line"]) { 
				TMLog(@"Got line setting!!");
				
				[self doLine:setting];
			} else {
				// This normally should be int=int (width specificator)
				// Try to split by '='
				NSArray* keyValuePair = [setting componentsSeparatedByString:@"="];
				
				if([keyValuePair count] != 2) {
					NSException *ex = [NSException exceptionWithName:@"WIDTH" 
											  reason:[NSString stringWithFormat:@"Width '%@' is invalid", setting] userInfo:nil];
					@throw ex;		
				}
				
				// Get integer values
				NSNumber* glyphNo = [NSNumber numberWithInt:[[keyValuePair objectAtIndex:0] intValue]];
				NSNumber* widthValue = [NSNumber numberWithInt:[[keyValuePair objectAtIndex:1] intValue]];
				
				[m_pGlyphWidths setObject:widthValue forKey:glyphNo];
			}
		}
	}
	
	return self;
}

- (void) doRange:(NSString*)setting {
	// Parse [range CODESET=first_frame] or [range CODESET #start-end=first_frame]
	// Format taken from StepMania to achive some compatibility
	
	NSArray* keyValuePair = [setting componentsSeparatedByString:@"="];
	if([keyValuePair count] != 2) {
		NSException *ex = [NSException exceptionWithName:@"RANGE" 
								  reason:[NSString stringWithFormat:@"Range '%@' is invalid", setting] userInfo:nil];
		@throw ex;		
	}
	
	// The value part
	NSString* value = [keyValuePair objectAtIndex:1];
	
	// Parse the key part
	NSString* keyPart = [[keyValuePair objectAtIndex:0] stringByReplacingOccurrencesOfString:@"range " withString:@""];
	NSArray* keySettings = [keyPart componentsSeparatedByString:@" "];
	
	int iCount = -1;
	int iFirst = 0;
	
	if([keySettings count] == 1) {
		// CODEPAGE only
		TMLog(@"Got codepage to map '%@'!", keyPart);
		[self mapRange:keyPart mapOffset:iFirst glyphNo:[value intValue] count:iCount];
		
	} else if([keySettings count] == 2) {
		// Full house
		// Exception
		NSException *ex = [NSException exceptionWithName:@"RANGE" 
								  reason:@"Range full key specifier is currently not supported!" userInfo:nil];
		@throw ex;				
		
	} else {
		// Exception
		NSException *ex = [NSException exceptionWithName:@"RANGE" 
								  reason:[NSString stringWithFormat:@"Range key specifier '%@' is invalid", keyPart] userInfo:nil];
		@throw ex;				
	}
}

- (void) doLine:(NSString*)setting {
	// Parse [line id=char1char2char3char4]
	// Format taken from StepMania to achive some compatibility
	
	NSArray* keyValuePair = [setting componentsSeparatedByString:@"="];
	if([keyValuePair count] != 2) {
		NSException *ex = [NSException exceptionWithName:@"LINE" 
												  reason:[NSString stringWithFormat:@"LINE '%@' is invalid", setting] userInfo:nil];
		@throw ex;		
	}
	
	// The value part
	NSString* value = [keyValuePair objectAtIndex:1];
	
	// Parse the key part
	NSString* keyPart = [[keyValuePair objectAtIndex:0] stringByReplacingOccurrencesOfString:@"line " withString:@""];	
	int lineNr = [keyPart intValue];
	
	if(lineNr > [m_pTexture rows]) {
		NSException *ex = [NSException exceptionWithName:@"LINE" 
												  reason:[NSString stringWithFormat:@"LINE %d is out of bounds", lineNr] userInfo:nil];
		@throw ex;		
	}

	if([value length] > [m_pTexture cols]) {
		NSException *ex = [NSException exceptionWithName:@"LINE" 
												  reason:[NSString stringWithFormat:@"LINE %d is out of bounds (width=%d)", lineNr, [value length]] userInfo:nil];
		@throw ex;		
	}	
	
	// Get the data and get chars out of it
	int i;
	int iFirstFrame = lineNr * [m_pTexture cols];
	
	for(i=0; i<[value length]; ++i) {
		NSNumber* num = [NSNumber numberWithInt:iFirstFrame+i];
		NSString* s = [NSString stringWithFormat:@"%C", [value characterAtIndex:i]];
		
		[m_pCharToGlyphNo setObject:num forKey:s];
		TMLog(@"[line] Mapped '%@' as %d", s, [num intValue]);
	}	
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
		NSString* s = [NSString stringWithFormat:@"%C", c];
		
		[m_pCharToGlyphNo setObject:num forKey:s];
				
		TMLog(@"[range] Mapped '%C' as %d", c, [num intValue]);
		
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
			int glyphId = i*cols+j;
			
			Glyph* glyph = [[Glyph alloc] initWithFrameId:glyphId];			
			glyph.m_pFontPage = self;		
			
			// Check glyph width in this font page
			NSNumber* gw = [m_pGlyphWidths objectForKey:[NSNumber numberWithInt:glyphId]];
			if(gw) {
				glyph.m_fWidth = [gw floatValue];
			} else {			
				glyph.m_fWidth = glyphWidth;
			}
			
			glyph.m_fHeight = glyphHeight;
			
			[m_aGlyphs addObject:glyph];				
		}
	}
}

@end


@interface Font (Private)
- (void) parseDefaultSettings;
@end


@implementation Font

- (id) initWithName:(NSString*)name andConfig:(NSDictionary*)config {
	self = [super init];
	if(!self)
		return nil;
	
	m_sFontName = name;
	m_pConfig = [config retain];
	
	m_bMultipage = NO;
	m_pCharToGlyph = [[NSMutableDictionary alloc] initWithCapacity:256];
	m_aPages = [[NSMutableArray alloc] initWithCapacity:6];
		
	return self;
}

// This does the real loading work
- (void) load {
	TMLog(@"Loading the %@ font...", m_sFontName);
	
	// Check for multiple pages
	NSDictionary* pages = [m_pConfig objectForKey:@"pages"];
	if(pages) {
		TMLog(@"Got a pages config entry. possible multiple pages. check");
		if([[pages allKeys] count] > 1) {
			TMLog(@"MULTIPLE PAGES found in config");
			m_bMultipage = YES;
		}
	}
	
	// Ok. We must parse all default settings
	[self parseDefaultSettings];
	
	// Try to find a resource which has a matching name	
	if(m_bMultipage) {
		
		// Parse pages from config. every key is the page name and the value is the settings array
		NSArray* allPageNames = [pages allKeys];
		
		int i = 0;
		for(; i<[allPageNames count]; ++i) {
			NSString* pageName = [allPageNames objectAtIndex:i];
			TMLog(@"Found page '%@'", pageName);
			
			// Japanese 16px[kanji1]
			NSString* pageResourceName = [NSString stringWithFormat:@"%@[%@]", m_sFontName, pageName];			
			NSArray* pageSettings = [pages objectForKey:pageName];							
			TMResource* resource = [[[FontManager sharedInstance] textures] getResource:pageResourceName];			
			if(!resource) {
				NSException *ex = [NSException exceptionWithName:@"ResourceNotFound" 
										reason:[NSString stringWithFormat:@"Resource '%@' is not found", pageResourceName] userInfo:nil];
				@throw ex;
			}
			
			FontPage* page = [[FontPage alloc] initWithResource:resource andSettings:pageSettings];
			
			if([pageName isEqualToString:@"main"]) {				
				// Add as default page
				m_pDefaultPage = page;			
				[m_aPages addObject:m_pDefaultPage];				
				
			} else {
				
				// Add this page
				[m_aPages addObject: page];								
			}
			
			// Now add real glyphs
			TMFramedTexture* tex = (TMFramedTexture*)[resource resource];
			[page setupGlyphsFromTexture:tex andConfig:m_pConfig];
		}		
		
	} else {
		
		// if we have no multiple pages
		TMResource* mainPage = [[[FontManager sharedInstance] textures] getResource:m_sFontName];
		if(mainPage) {
			TMLog(@"Found the texture resource!");

			// It can be so that the [main] page config is specified.. so we must check that
			if([[pages allKeys] count] == 1) { // Not multipage but still have config
				m_pDefaultPage = [[FontPage alloc] initWithResource:mainPage andSettings:[[pages allValues] objectAtIndex:0]];						
				
			} else {			
				m_pDefaultPage = [[FontPage alloc] initWithResource:mainPage andSettings:nil];						
			}

			[m_aPages addObject:m_pDefaultPage];
			
			// Check how much frames it has
			TMFramedTexture* tex = (TMFramedTexture*)[mainPage resource];

			if(tex.totalFrames == 15) {
				TMLog(@"MAP deafult to numbers!");
				[m_pDefaultPage mapRange:@"numbers" mapOffset:0 glyphNo:0 count:-1];
				
			} else if(tex.totalFrames == 128) {
				TMLog(@"MAP deafult to ascii!");
				[m_pDefaultPage mapRange:@"ascii" mapOffset:0 glyphNo:0 count:-1];
				
			} else if(tex.totalFrames == 256) {
				TMLog(@"MAP deafult to cp1252!");
				[m_pDefaultPage mapRange:@"cp1252" mapOffset:0 glyphNo:0 count:-1];
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

- (void) parseDefaultSettings {
	if([m_pConfig objectForKey:@"AddToAllWidths"]) {
		
	}
	
	if([m_pConfig objectForKey:@"ScaleAllWidthsBy"]) {
		
	}
	
	if([m_pConfig objectForKey:@"DrawExtraPixelsLeft"]) {
		
	}
	
	if([m_pConfig objectForKey:@"DrawExtraPixelsRight"]) {
		
	}
	
	if([m_pConfig objectForKey:@"LineSpacing"]) {
		
	}
	
	if([m_pConfig objectForKey:@"Top"]) {
		
	}
	
	if([m_pConfig objectForKey:@"Baseline"]) {
		
	}
	
	if([m_pConfig objectForKey:@"DefaultWidth"]) {
		
	}
	
	if([m_pConfig objectForKey:@"AdvanceExtraPixels"]) {
		
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
			[[[g m_pFontPage] texture] drawFrame:[g m_nTextureFrame] atPoint:CGPointMake(curPoint.x+[g m_fWidth]/2, curPoint.y+[g m_fHeight]/2)];
			glDisable(GL_BLEND);
			
			curPoint = CGPointMake(curPoint.x+[g m_fWidth], point.y);
		} else {
			TMLog(@"Can't find mapping for '%@' char", mapTester);
		}
	}
}

@end
