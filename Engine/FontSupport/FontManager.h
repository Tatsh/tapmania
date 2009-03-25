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
	ResourcesLoader*	m_pCurrentFontResources;		// Current theme's fonts
}

@property (retain, nonatomic, readonly, getter=fonts) ResourcesLoader* m_pCurrentFontResources;

// Methods
- (void) loadFonts:(NSString*)fontDirPath;

// Printing text
- (void) printText:(NSString*)str withFont:(NSString*) startPoint:(CGPoint)point;

+ (FontManager *) sharedInstance;

@end
