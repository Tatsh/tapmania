//
//  ThemeManager.h
//  TapMania
//
//  Created by Alex Kremer on 03.02.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FontManager.h"
#import "ResourcesLoader.h"

@class ThemeMetrics, ResourcesLoader, Texture2D;

#define kDefaultThemeName		@"default"
#define kDefaultNoteSkinName	@"default"

@interface ThemeManager : NSObject <ResourcesLoaderSupport> {
	NSString*			m_sCurrentThemeName;		// Current theme
	NSString*			m_sCurrentNoteskinName;
	
	ThemeMetrics*		m_pCurrentThemeMetrics;		// The currently loaded theme metrics object
	ResourcesLoader*	m_pCurrentThemeResources;	// Current theme's resources (graphics)
	ResourcesLoader*	m_pCurrentNoteSkinResources;
	
	NSMutableArray*		m_aThemesList;	// A list of existing themes (directories in the 'themes' folder which contains metrics file)
	NSMutableArray*		m_aNoteskinsList;
}

@property (retain, nonatomic, readonly, getter=themeName) NSString* m_sCurrentThemeName;
@property (retain, nonatomic, readonly, getter=themeList) NSMutableArray* m_aThemesList;
@property (retain, nonatomic, readonly, getter=noteskinName) NSString* m_sCurrentNoteskinName;
@property (retain, nonatomic, readonly, getter=noteskinList) NSMutableArray* m_aNoteskinsList;

@property (retain, nonatomic, readonly, getter=theme) ResourcesLoader* m_pCurrentThemeResources;
@property (retain, nonatomic, readonly, getter=noteSkin) ResourcesLoader* m_pCurrentNoteSkinResources;

- (void) selectTheme:(NSString*) themeName;		// This will load the metrics file of the passed theme if that theme exists
- (void) selectNoteskin:(NSString*) skinName;	

/* Metric stuff */
- (int) intMetric:(NSString*) metricKey;
- (float) floatMetric:(NSString*) metricKey;
- (NSString*) stringMetric:(NSString*) metricKey;

/* Theme textures */
- (Texture2D*) texture:(NSString*) textureKey;
- (Texture2D*) skinTexture:(NSString*) textureKey;

+ (ThemeManager *) sharedInstance;

@end
