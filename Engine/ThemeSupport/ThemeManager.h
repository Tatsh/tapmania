//
//  ThemeManager.h
//  TapMania
//
//  Created by Alex Kremer on 03.02.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResourcesLoader.h"

@class ThemeMetrics, ResourcesLoader;

#define kDefaultThemeName	@"default"

@interface ThemeManager : NSObject <ResourcesLoaderSupport> {
	NSString*			m_sCurrentThemeName;		// Current theme
	ThemeMetrics*		m_pCurrentThemeMetrics;		// The currently loaded theme metrics object
	ResourcesLoader*	m_pCurrentThemeResources;	// Current theme's resources (graphics)
	ResourcesLoader*	m_pCurrentNoteSkinResources;
	
	NSMutableArray* m_aThemesList;	// A list of existing themes (directories in the 'themes' folder which contains metrics file)
}

@property (retain, nonatomic, readonly, getter=themeName) NSString* m_sCurrentThemeName;
@property (retain, nonatomic, readonly, getter=themeList) NSMutableArray* m_aThemesList;

@property (retain, nonatomic, readonly, getter=theme) ResourcesLoader* m_pCurrentThemeResources;
@property (retain, nonatomic, readonly, getter=noteSkin) ResourcesLoader* m_pCurrentNoteSkinResources;

- (void) selectTheme:(NSString*) themeName;		// This will load the metrics file of the passed theme if that theme exists
- (int) intMetric:(NSString*) metricKey;
- (float) floatMetric:(NSString*) metricKey;
- (NSString*) stringMetric:(NSString*) metricKey;

+ (ThemeManager *) sharedInstance;

@end
