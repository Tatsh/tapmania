//
//  FontManager.h
//  TapMania
//
//  Created by Alex Kremer on 25.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResourcesLoader.h"

@interface FontManager : NSObject <ResourcesLoaderSupport> {
	ResourcesLoader*		m_pCurrentFontResources;		// Current theme's font textures
	NSMutableDictionary*	m_pFonts;						// Map with Font objects
}

@property (retain, nonatomic, readonly, getter=textures) ResourcesLoader* m_pCurrentFontResources;
@property (retain, nonatomic, readonly, getter=fonts) NSMutableDictionary* m_pFonts;

// Methods
- (void) loadFonts:(NSString*)fontDirPath;
- (void) loadFont:(NSString*)fontPath andName:(NSString*)name;

+ (FontManager *) sharedInstance;

@end
