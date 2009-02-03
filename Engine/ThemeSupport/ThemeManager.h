//
//  ThemeManager.h
//  TapMania
//
//  Created by Alex Kremer on 03.02.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThemeMetrics;

#define kDefaultThemeName	@"default"

@interface ThemeManager : NSObject {
	NSString* mCurrentThemeName;		// Current theme
	ThemeMetrics* mCurrentThemeMetrics;	// The currently loaded theme metrics object
	
	NSMutableArray* mThemesList;	// A list of existing themes (directories in the 'themes' folder which contains metrics file)
}

@property (retain, nonatomic, readonly, getter=metrics) ThemeMetrics* mCurrentThemeMetrics;
@property (retain, nonatomic, readonly, getter=themeName) NSString* mCurrentThemeName;
@property (retain, nonatomic, readonly, getter=themeList) NSMutableArray* mThemesList;

- (void) selectTheme:(NSString*) themeName;		// This will load the metrics file of the passed theme if that theme exists

+ (ThemeManager *) sharedInstance;

@end
