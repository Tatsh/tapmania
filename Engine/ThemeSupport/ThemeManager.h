//
//  $Id$
//  ThemeManager.h
//  TapMania
//
//  Created by Alex Kremer on 03.02.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FontManager.h"
#import "ResourcesLoader.h"

@class Metrics, ResourcesLoader, Texture2D, TMSound, TMFramedTexture;

#define BOOL_METRIC(key) [[ThemeManager sharedInstance] boolMetric:key]
#define INT_METRIC(key) [[ThemeManager sharedInstance] intMetric:key]
#define FLOAT_METRIC(key) [[ThemeManager sharedInstance] floatMetric:key]
#define STR_METRIC(key) [[ThemeManager sharedInstance] stringMetric:key]
#define RECT_METRIC(key) [[ThemeManager sharedInstance] rectMetric:key]
#define POINT_METRIC(key) [[ThemeManager sharedInstance] pointMetric:key]
#define SIZE_METRIC(key) [[ThemeManager sharedInstance] sizeMetric:key]
#define ARRAY_METRIC(key) [[ThemeManager sharedInstance] arrayMetric:key]
#define DICT_METRIC(key) [[ThemeManager sharedInstance] dictMetric:key]

#define INT_SKIN_METRIC(key) [[ThemeManager sharedInstance] intSkinMetric:key]
#define FLOAT_SKIN_METRIC(key) [[ThemeManager sharedInstance] floatSkinMetric:key]
#define STR_SKIN_METRIC(key) [[ThemeManager sharedInstance] stringSkinMetric:key]
#define RECT_SKIN_METRIC(key) [[ThemeManager sharedInstance] rectSkinMetric:key]
#define POINT_SKIN_METRIC(key) [[ThemeManager sharedInstance] pointSkinMetric:key]
#define SIZE_SKIN_METRIC(key) [[ThemeManager sharedInstance] sizeSkinMetric:key]
#define ARRAY_SKIN_METRIC(key) [[ThemeManager sharedInstance] arraySkinMetric:key];
#define DICT_SKIN_METRIC(key) [[ThemeManager sharedInstance] dictSkinMetric:key]

#define TEXTURE(key) [[ThemeManager sharedInstance] texture:key]
#define SKIN_TEXTURE(key) [[ThemeManager sharedInstance] skinTexture:key]
#define SOUND(key) [[ThemeManager sharedInstance] sound:key]

#define kDefaultThemeName        @"default"
#define kDefaultNoteSkinName    @"default"
#define kDefaultMode            @"Skyscraper"

@interface ThemeManager : NSObject <ResourcesLoaderSupport>
{
    NSString *m_sCurrentThemeName;        // Current theme
    NSString *m_sCurrentNoteskinName;
    NSString *m_sCurrentMode;                // Current view mode; skyscraper or landscape

    Metrics *m_pCurrentThemeMetrics;            // The currently loaded theme metrics object
    Metrics *m_pCurrentNoteSkinMetrics;        // The currently loaded noteskin metrics object

    ResourcesLoader *m_pCurrentThemeResources;        // Current theme's resources (graphics)
    ResourcesLoader *m_pCurrentThemeSoundResources;    // Current theme's sounds
    ResourcesLoader *m_pCurrentThemeWebResources;
    ResourcesLoader *m_pCurrentNoteSkinResources;

    NSMutableArray *m_aThemesList;    // A list of existing themes (directories in the 'themes' folder which contains metrics file)
    NSMutableArray *m_aNoteskinsList;
}

@property(retain, nonatomic, readonly, getter=themeName) NSString *m_sCurrentThemeName;
@property(retain, nonatomic, readonly, getter=themeList) NSMutableArray *m_aThemesList;
@property(retain, nonatomic, readonly, getter=noteskinName) NSString *m_sCurrentNoteskinName;
@property(retain, nonatomic, readonly, getter=noteskinList) NSMutableArray *m_aNoteskinsList;

@property(retain, nonatomic, readonly, getter=theme) ResourcesLoader *m_pCurrentThemeResources;
@property(retain, nonatomic, readonly, getter=sounds) ResourcesLoader *m_pCurrentThemeSoundResources;
@property(retain, nonatomic, readonly, getter=web) ResourcesLoader *m_pCurrentThemeWebResources;
@property(retain, nonatomic, readonly, getter=noteSkin) ResourcesLoader *m_pCurrentNoteSkinResources;

- (void)selectTheme:(NSString *)themeName;        // This will load the metrics file of the passed theme if that theme exists
- (void)selectNoteskin:(NSString *)skinName;

/* Metric stuff */
- (BOOL)boolMetric:(NSString *)metricKey;

- (int)intMetric:(NSString *)metricKey;

- (float)floatMetric:(NSString *)metricKey;

- (NSString *)stringMetric:(NSString *)metricKey;

- (CGRect)rectMetric:(NSString *)metricKey;

- (CGPoint)pointMetric:(NSString *)metricKey;

- (CGSize)sizeMetric:(NSString *)metricKey;

- (NSArray *)arrayMetric:(NSString *)metricKey;

- (NSDictionary *)dictMetric:(NSString *)metricKey;

/* Same for noteskin metrics */
- (int)intSkinMetric:(NSString *)metricKey;

- (float)floatSkinMetric:(NSString *)metricKey;

- (NSString *)stringSkinMetric:(NSString *)metricKey;

- (CGRect)rectSkinMetric:(NSString *)metricKey;

- (CGPoint)pointSkinMetric:(NSString *)metricKey;

- (CGSize)sizeSkinMetric:(NSString *)metricKey;

- (NSArray *)arraySkinMetric:(NSString *)metricKey;

- (NSDictionary *)dictSkinMetric:(NSString *)metricKey;

/* Theme stuff */
- (TMSound *)sound:(NSString *)soundKey;

- (Texture2D *)texture:(NSString *)textureKey;

- (TMFramedTexture *)skinTexture:(NSString *)textureKey;

/* Themes/Noteskins upload support */
- (void)addSkinsFrom:(NSString *)rootDir;

+ (ThemeManager *)sharedInstance;

@end
