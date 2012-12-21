//
//  $Id$
//  FontManager.h
//  TapMania
//
//  Created by Alex Kremer on 25.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResourcesLoader.h"

@class Font, Quad;

@interface FontManager : NSObject <ResourcesLoaderSupport>
{
    ResourcesLoader *m_pCurrentFontResources;        // Current theme's font textures
    NSMutableDictionary *m_pFonts;                        // Map with Font objects
    NSMutableDictionary *m_pRedirects;                    // Map with redirects

    Font *m_pDefaultFont;                    // Direct link to the default font
}

@property(retain, nonatomic, readonly, getter=textures) ResourcesLoader *m_pCurrentFontResources;
@property(retain, nonatomic, readonly, getter=fonts) NSMutableDictionary *m_pFonts;
@property(retain, nonatomic, readonly, getter=defaultFont) Font *m_pDefaultFont;

// Methods
- (void)loadFonts:(NSString *)fontDirPath;

- (void)loadFont:(NSString *)fontPath andName:(NSString *)name;

- (void)addRedirect:(NSString *)alias to:(NSString *)real;

- (Font *)getFont:(NSString *)fontName;

- (CGSize)getStringWidthAndHeight:(NSString *)str usingFont:(NSString *)fontName;

// Drawing text
- (Quad *)getTextQuad:(NSString *)text usingFont:(NSString *)fontName;

+ (FontManager *)sharedInstance;

@end
