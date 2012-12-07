//
//  $Id$
//  ThemeManager.m
//  ThemeManager
//
//  Created by Alex Kremer on 03.02.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "ThemeManager.h"
#import "Metrics.h"
#import "ResourcesLoader.h"
#import "TMSound.h"
#import "TapMania.h"
#import "DisplayUtil.h"
#import "VersionInfo.h"
#import "GameState.h"

// This is a singleton class, see below
static ThemeManager *sharedThemeManagerDelegate = nil;
extern TMGameState*	g_pGameState;

@interface ThemeManager (Private)
- (NSObject*) lookUpNode:(NSString*) key from:(NSObject*) rootObj;
- (BOOL) dirIsTheme:(NSString*)path;
- (BOOL) dirIsNoteskin:(NSString *)path;
@end


@implementation ThemeManager

@synthesize m_aThemesList, m_sCurrentThemeName, m_aNoteskinsList, m_sCurrentNoteskinName;
@synthesize m_pCurrentThemeResources, m_pCurrentThemeWebResources, m_pCurrentNoteSkinResources, m_pCurrentThemeSoundResources;

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	/* We must list all the themes and store them into the mThemesList array */
	m_aThemesList = [[NSMutableArray alloc] initWithCapacity:1];
	m_aNoteskinsList = [[NSMutableArray alloc] initWithCapacity:1];
	
	int i;	
	
	NSString* themesDir = [[NSBundle mainBundle] pathForResource:@"themes" ofType:nil];	
	TMLog(@"Point themes dir to '%@'!", themesDir);

	NSString* noteskinsDir = [[NSBundle mainBundle] pathForResource:@"noteskins" ofType:nil];	
	TMLog(@"Point noteskins dir to '%@'!", noteskinsDir);
	
	NSArray* themesDirContents = [[NSFileManager defaultManager] directoryContentsAtPath:themesDir];
	NSArray* noteskinsDirContents = [[NSFileManager defaultManager] directoryContentsAtPath:noteskinsDir];
	
	// Raise error if empty themes dir
	if([themesDirContents count] == 0 || [noteskinsDirContents count] == 0) {
		TMLog(@"Oops! Themes dir or noteskins dir is empty. This should never happen."); // We should have the default themes always
		return nil;
	}
	
	// Iterate through the themes
	for(i = 0; i<[themesDirContents count]; i++) {		
		NSString* themeDirName = [themesDirContents objectAtIndex:i];
		NSString* path = [themesDir stringByAppendingFormat:@"/%@/Metrics.plist", themeDirName];
	
		// Check the Metrics.plist file
		if([[NSFileManager defaultManager] fileExistsAtPath:path]) {			
			// Ok. Looks like a valid tapmania theme.. need to check the SystemVersion number
			NSDictionary* themeMetrics = [NSDictionary dictionaryWithContentsOfFile:path];
			NSNumber* version = [themeMetrics objectForKey:@"ThemeSystemVersion"];
			
			if(version != nil && [version doubleValue]==TAPMANIA_THEME_VERSION) {
				[m_aThemesList addObject:themeDirName];
				TMLog(@"Added theme '%@' to themes list.", themeDirName);
			}
		}
	}

	// Iterate through the noteskins
	for(i = 0; i<[noteskinsDirContents count]; i++) {		
		NSString* noteskinDirName = [noteskinsDirContents objectAtIndex:i];
		NSString* path = [noteskinsDir stringByAppendingFormat:@"/%@/Metrics.plist", noteskinDirName];
		
		// Check the Metrics.plist file
		if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
			// Ok. Looks like a valid tapmania noteskin.. need to check the SystemVersion number
			NSDictionary* skinMetrics = [NSDictionary dictionaryWithContentsOfFile:path];
			NSNumber* version = [skinMetrics objectForKey:@"NoteskinSystemVersion"];
			
			if(version != nil && [version doubleValue]==TAPMANIA_NOTESKIN_VERSION) {
				[m_aNoteskinsList addObject:noteskinDirName];
				TMLog(@"Added noteskin '%@' to noteskins list.", noteskinDirName);
			}
		}
	}
	
	// Set mode
	if(g_pGameState->m_bLandscape) {
		m_sCurrentMode = [@"Landscape" retain];
	} else {
		m_sCurrentMode = [kDefaultMode retain];
	}
	
	return self;
}

- (void) selectTheme:(NSString*) themeName {
	
	if([m_aThemesList containsObject:themeName]) {
		m_sCurrentThemeName = themeName;
		
		NSString* themesDir = [[NSBundle mainBundle] pathForResource:@"themes" ofType:nil];	
		
		NSString* themeGraphicsPath = [themesDir stringByAppendingFormat:@"/%@/Graphics/", m_sCurrentThemeName];
		NSString* themeWebPath = [themesDir stringByAppendingFormat:@"/%@/WebServer/", m_sCurrentThemeName];
		NSString* themeFontsPath	= [themesDir stringByAppendingFormat:@"/%@/Fonts/", m_sCurrentThemeName];
		NSString* themeSoundsPath	= [themesDir stringByAppendingFormat:@"/%@/Sounds/", m_sCurrentThemeName];
		
		NSString* filePath = [themesDir stringByAppendingFormat:@"/%@/Metrics.plist", m_sCurrentThemeName];
		NSString* dpFilePath = [themesDir stringByAppendingFormat:@"/%@/%@_Metrics.plist",
                                m_sCurrentThemeName, [DisplayUtil getDeviceDisplayString]];
		
        
		if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {		
			m_pCurrentThemeMetrics	 = [[Metrics alloc] initWithContentsOfFile:filePath];
			m_pCurrentThemeResources = [[ResourcesLoader alloc] initWithPath:themeGraphicsPath type:kResourceLoaderGraphics andDelegate:self];
			m_pCurrentThemeSoundResources = [[ResourcesLoader alloc] initWithPath:themeSoundsPath type:kResourceLoaderSounds andDelegate:self];
			m_pCurrentThemeWebResources = [[ResourcesLoader alloc] initWithPath:themeWebPath type:kResourceLoaderWeb andDelegate:self];
			
			// Use font manager to load up fonts
			[[FontManager sharedInstance] loadFonts:themeFontsPath];
						
			TMLog(@"Metrics and resources are loaded for theme '%@'.", m_sCurrentThemeName);
		        
            if([[NSFileManager defaultManager] fileExistsAtPath:dpFilePath]) {
                TMLog(@"There is a resolution-perfect version with overrides. Override from there...");
                
                [m_pCurrentThemeMetrics overrideWith:[[[Metrics alloc] initWithContentsOfFile:dpFilePath] autorelease]];
            }
            
		} else {
			TMLog(@"Couldn't load Metrics.plist file from the selected theme! This should not happen.");
			exit(127);
		}
	} else {
		TMLog(@"Theme '%@' is no longer available. Switch to default.", themeName);
		[self selectTheme:kDefaultThemeName];
	}
}

- (void) selectNoteskin:(NSString*) skinName {
	if([m_aNoteskinsList containsObject:skinName]) {
		
		if(m_pCurrentNoteSkinMetrics) [m_pCurrentNoteSkinMetrics release];
		if(m_pCurrentNoteSkinResources) [m_pCurrentNoteSkinResources release];
		
		m_sCurrentNoteskinName = skinName;		

		NSString* noteskinsDir = [[NSBundle mainBundle] pathForResource:@"noteskins" ofType:nil];	
		NSString* skinPath =	 [noteskinsDir stringByAppendingPathComponent:skinName];
		NSString* filePath =	 [noteskinsDir stringByAppendingFormat:@"/%@/Metrics.plist", m_sCurrentNoteskinName];
        NSString* dpFilePath = [noteskinsDir stringByAppendingFormat:@"/%@/%@_Metrics.plist",
                                m_sCurrentNoteskinName, [DisplayUtil getDeviceDisplayString]];
				
		m_pCurrentNoteSkinMetrics	= [[Metrics alloc] initWithContentsOfFile:filePath];
		m_pCurrentNoteSkinResources = [[ResourcesLoader alloc] initWithPath:skinPath type:kResourceLoaderNoteSkin andDelegate:self];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:dpFilePath]) {
            TMLog(@"There is a resolution-perfect version with overrides. Override from there...");
            
            [m_pCurrentNoteSkinMetrics overrideWith:[[[Metrics alloc] initWithContentsOfFile:dpFilePath] autorelease]];
        }
	} else {
		TMLog(@"NoteSkin '%@' is no longer available. Switch to default.", skinName);
		[self selectNoteskin:kDefaultNoteSkinName];
	}
}

- (BOOL) boolMetric:(NSString*) metricKey {
	NSObject* node = [self lookUpNode:metricKey from:m_pCurrentThemeMetrics];
	if(!node) 
		return NO; // Defualt value
	
	return [(NSNumber*)node	boolValue];
}

- (int) intMetric:(NSString*) metricKey {
	NSObject* node = [self lookUpNode:metricKey from:m_pCurrentThemeMetrics];
	if(!node) 
		return 0; // Defualt value
	
	return [(NSNumber*)node	intValue];
}

- (float) floatMetric:(NSString*) metricKey {
	NSObject* node = [self lookUpNode:metricKey from:m_pCurrentThemeMetrics];
	if(!node) 
		return 0.0f; // Defualt value
	
	return [(NSNumber*)node	floatValue];
}

- (NSString*) stringMetric:(NSString*) metricKey {
	NSObject* node = [self lookUpNode:metricKey from:m_pCurrentThemeMetrics];
	if(!node) 
		return nil;
	
	return [[NSString stringWithString:(NSString*)node] autorelease];
}

- (CGRect) rectMetric:(NSString*) metricKey {
	NSObject* node = [self lookUpNode:metricKey from:m_pCurrentThemeMetrics];
	if(!node || ![node isKindOfClass:[NSDictionary class]]) 
		return CGRectMake(0, 0, 0, 0); // Defualt value

	int x = [[(NSDictionary*)node objectForKey:@"X"] intValue];
	int y = [[(NSDictionary*)node objectForKey:@"Y"] intValue];
	int width = [[(NSDictionary*)node objectForKey:@"Width"] intValue];
	int height = [[(NSDictionary*)node objectForKey:@"Height"] intValue];
	
	return CGRectApplyAffineTransform( CGRectMake(x, y, width, height), [TapMania sharedInstance].m_Transform);
}

- (CGPoint) pointMetric:(NSString*) metricKey {
	NSObject* node = [self lookUpNode:metricKey from:m_pCurrentThemeMetrics];
	if(!node || ![node isKindOfClass:[NSDictionary class]]) 
		return CGPointMake(0, 0); // Defualt value
	
	int x = [[(NSDictionary*)node objectForKey:@"X"] intValue];
	int y = [[(NSDictionary*)node objectForKey:@"Y"] intValue];
	
	return CGPointApplyAffineTransform( CGPointMake(x, y), [TapMania sharedInstance].m_Transform);
}

- (CGSize) sizeMetric:(NSString*) metricKey {
	NSObject* node = [self lookUpNode:metricKey from:m_pCurrentThemeMetrics];
	if(!node || ![node isKindOfClass:[NSDictionary class]]) 
		return CGSizeMake(0, 0); // Defualt value
	
	int width = [[(NSDictionary*)node objectForKey:@"Width"] intValue];
	int height = [[(NSDictionary*)node objectForKey:@"Height"] intValue];
	
	return CGSizeMake(width, height);
}

- (NSArray*) arrayMetric:(NSString*) metricKey {
	NSObject* node = [self lookUpNode:metricKey from:m_pCurrentThemeMetrics];
	if(!node || ![node isKindOfClass:[NSArray class]]) 
		return nil;
	
	return (NSArray*)node;
}

- (NSDictionary*) dictMetric:(NSString*) metricKey {
	NSObject* node = [self lookUpNode:metricKey from:m_pCurrentThemeMetrics];
	if(!node || ![node isKindOfClass:[NSDictionary class]]) 
		return nil;
	
	return (NSDictionary*)node;	
}

/* Same for skin metrics */
- (int) intSkinMetric:(NSString*) metricKey {
	NSObject* node = [self lookUpNode:metricKey from:m_pCurrentNoteSkinMetrics];
	if(!node) 
		return 0; // Defualt value
	
	return [(NSNumber*)node	intValue];
}

- (float) floatSkinMetric:(NSString*) metricKey {
	NSObject* node = [self lookUpNode:metricKey from:m_pCurrentNoteSkinMetrics];
	if(!node) 
		return 0.0f; // Defualt value
	
	return [(NSNumber*)node	floatValue];
}

- (NSString*) stringSkinMetric:(NSString*) metricKey {
	NSObject* node = [self lookUpNode:metricKey from:m_pCurrentNoteSkinMetrics];
	if(!node) 
		return nil;
	
	return [[NSString stringWithString:(NSString*)node] autorelease];
}

- (CGRect) rectSkinMetric:(NSString*) metricKey {
	NSObject* node = [self lookUpNode:metricKey from:m_pCurrentNoteSkinMetrics];
	if(!node || ![node isKindOfClass:[NSDictionary class]]) 
		return CGRectMake(0, 0, 0, 0); // Defualt value
	
	int x = [[(NSDictionary*)node objectForKey:@"X"] intValue];
	int y = [[(NSDictionary*)node objectForKey:@"Y"] intValue];
	int width = [[(NSDictionary*)node objectForKey:@"Width"] intValue];
	int height = [[(NSDictionary*)node objectForKey:@"Height"] intValue];
	
	return CGRectApplyAffineTransform( CGRectMake(x, y, width, height), [TapMania sharedInstance].m_Transform);
}

- (CGPoint) pointSkinMetric:(NSString*) metricKey {
	NSObject* node = [self lookUpNode:metricKey from:m_pCurrentNoteSkinMetrics];
	if(!node || ![node isKindOfClass:[NSDictionary class]]) 
		return CGPointMake(0, 0); // Defualt value
	
	int x = [[(NSDictionary*)node objectForKey:@"X"] intValue];
	int y = [[(NSDictionary*)node objectForKey:@"Y"] intValue];
	
	return CGPointApplyAffineTransform( CGPointMake(x, y), [TapMania sharedInstance].m_Transform);
}

- (CGSize) sizeSkinMetric:(NSString*) metricKey {
	NSObject* node = [self lookUpNode:metricKey from:m_pCurrentNoteSkinMetrics];
	if(!node || ![node isKindOfClass:[NSDictionary class]]) 
		return CGSizeMake(0, 0); // Defualt value
	
	int width = [[(NSDictionary*)node objectForKey:@"Width"] intValue];
	int height = [[(NSDictionary*)node objectForKey:@"Height"] intValue];
	
	return CGSizeMake(width, height);
}

- (NSArray*) arraySkinMetric:(NSString*) metricKey {
	NSObject* node = [self lookUpNode:metricKey from:m_pCurrentNoteSkinMetrics];
	if(!node || ![node isKindOfClass:[NSArray class]]) 
		return nil;
	
	return (NSArray*)node;
}

- (NSDictionary*) dictSkinMetric:(NSString*) metricKey {
	NSObject* node = [self lookUpNode:metricKey from:m_pCurrentNoteSkinMetrics];
	if(!node || ![node isKindOfClass:[NSDictionary class]]) 
		return nil;
	
	return (NSDictionary*)node;	
}

- (Texture2D*) texture:(NSString*) textureKey {
	TMResource* resource = [m_pCurrentThemeResources getResource:textureKey];
	
	if(resource) {
		return (Texture2D*)[resource resource];
	}

	TMLog(@"NOT FOUND! Shit!!!");
	// TODO return some very default texture if not found
	return nil;
}

- (TMSound*) sound:(NSString*) soundKey {
	TMResource* resource = [m_pCurrentThemeSoundResources getResource:soundKey];
	
	if(resource) {
		return (TMSound*)[resource resource];
	}

	// Will not play the sound
	return nil;
}


- (TMFramedTexture*) skinTexture:(NSString*) textureKey {
	TMResource* resource = [m_pCurrentNoteSkinResources getResource:textureKey];
	if(resource) {
		return (TMFramedTexture*)[resource resource];
	}
	
	// TODO return some very default texture if not found
	return nil;	
}

// This is the private method which searches through the metrics tree to get the metric
- (NSObject*) lookUpNode:(NSString*) key from:(NSObject*) rootObj {
	
	// Key is of format: "SomeRootElement SomeInnerElement SomeEvenMoreInnerElement TheMetric"
	NSMutableArray* pathChunks = [NSMutableArray arrayWithArray:[key componentsSeparatedByString:@" "]];
	[pathChunks insertObject:m_sCurrentMode atIndex:0];
	
	NSObject* tmp = rootObj;
	int i;
	
	for(i=0; i<[pathChunks count]-1; ++i) {
		if(tmp != nil && ( [tmp isKindOfClass:[NSDictionary class]] || [tmp isKindOfClass:[Metrics class]])) {
			// Search next component
			tmp = [tmp objectForKey:[pathChunks objectAtIndex:i]];
		}
	}
	
	if(tmp != nil) {
		tmp = [[tmp objectForKey:[pathChunks lastObject]] retain];
	}
		
	return tmp;	// nil or not
}


/* ResourcesLoaderSupport delegate work */
- (BOOL) resourceTypeSupported:(NSString*) itemName {
	if([[itemName lowercaseString] hasSuffix:@".png"] || [[itemName lowercaseString] hasSuffix:@".jpg"] ||
	   [[itemName lowercaseString] hasSuffix:@".gif"] || [[itemName lowercaseString] hasSuffix:@".bmp"] ) 
	{ 
		return YES;
	}
	
	// Another way is redirection. .redir files therefore should also be accepted
	if([[itemName lowercaseString] hasSuffix:@".redir"]) {
		return YES;
	}
	
	// We are also going to support htm/html files for our built-in web server
	if([[itemName lowercaseString] hasSuffix:@".htm"] || [[itemName lowercaseString] hasSuffix:@".html"]) {
		return YES;
	}
	
	// Sounds
	if([[itemName lowercaseString] hasSuffix:@".mp3"] || [[itemName lowercaseString] hasSuffix:@".ogg"] ||
	   [[itemName lowercaseString] hasSuffix:@".caf"] || [[itemName lowercaseString] hasSuffix:@".wav"] )
	{
		return YES;
	}
		
	
	return NO;		
}

#pragma mark -
#pragma mark Support for theme/noteskin upload

- (void) addSkinsFrom:(NSString*)rootDir {
	// This is usually called after a smzip/zip was extracted
	// We will just recursively iterate over the whole package and try to find
	// all complete noteskins.
	NSFileManager* fMan = [NSFileManager defaultManager];
	TMLog(@"Going to test dir '%@' for skins...", rootDir);
	
	// Check whether this dir is a simfile dir already
	if( ![[rootDir lastPathComponent] hasPrefix:@"__MACOSX"] ) {
		if( [self dirIsTheme:rootDir] ) {
			TMLog(@"Found a potential Theme directory. try to add files from there..");
//			[self addThemeFromDir:rootDir];
			
			return;
			
		} else if( [self dirIsNoteskin:rootDir] ) {
			TMLog(@"Found a potential Noteskin directory. try to add files from there..");
			// [self addNoteskinFromDir:rootDir];
			
			return;
		}
	}
	
	// Otherwise we will need to iterate over the contents to see if we can
	// find directories with simfiles
	NSArray* rootDirContents = [fMan directoryContentsAtPath:rootDir];	
	
	// If the dir is empty, leave
	if([rootDirContents count] == 0) {
		return;
	}
	
	// Iterate over the contents
	for (NSString* item in rootDirContents) {
		if( [item hasPrefix:@"__MACOSX"] ) 
			continue;
		
		BOOL isDir = NO;
		NSString* path = [rootDir stringByAppendingPathComponent:item];
		
		if([fMan fileExistsAtPath:path isDirectory:&isDir] && isDir) {
			TMLog(@"Recursively try '%@'...", path);
			[self addSkinsFrom:path];
		}
	}
}

- (BOOL) dirIsTheme:(NSString*)path {
	NSArray* contents = [[NSFileManager defaultManager] directoryContentsAtPath:path];	
	
	TMLog(@"Test dir '%@' for theme contents...", path);
	
	for (NSString* file in contents) {		
		TMLog(@"Examine file/dir: %@", file);
		
		// If found a metrics file it could be a theme/noteskin. match
		if([file isEqualToString:@"Metrics.plist"]){
			// Read it in
			NSDictionary* plist = [NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:file]];
			NSNumber* version = [plist objectForKey:@"ThemeSystemVersion"];
			if( version != nil && TAPMANIA_THEME_VERSION == [version doubleValue] ) {				
				TMLog(@"Found a theme!");
				return YES;
			}
		} 
	}
	
	return NO;
}

- (BOOL) dirIsNoteskin:(NSString*)path {
	NSArray* contents = [[NSFileManager defaultManager] directoryContentsAtPath:path];	
	
	TMLog(@"Test dir '%@' for noteskin contents...", path);
		
	for (NSString* file in contents) {		
		TMLog(@"Examine file/dir: %@", file);
	
		// If found a metrics file it could be a theme/noteskin. match
		if([file isEqualToString:@"Metrics.plist"]){
			// Read it in
			NSDictionary* plist = [NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:file]];
			NSNumber* version = [plist objectForKey:@"NoteskinSystemVersion"];
			if( version != nil && TAPMANIA_NOTESKIN_VERSION == [version doubleValue] ) {				
				TMLog(@"Found a noteskin!");
				return YES;
			}
		} 
	}
	
	return NO;
}

- (void) addNoteskinFromDir:(NSString*)path {
//	NSString* curPath = [[self getSongsPath:kUserSongsPath] stringByAppendingPathComponent:[path lastPathComponent]];
//	BOOL isDir;
//	
//	// Check whether the Song already exists in the catalogue
//	if( [[NSFileManager defaultManager] fileExistsAtPath:curPath isDirectory:&isDir] ) {
//		// TODO: handle situation. report to user.
//		return;
//	}
//	
//	// TODO handle errors
//	NSError* err;
//	
//	if([[NSFileManager defaultManager] copyItemAtPath:path toPath:curPath error:&err]) {
//		if([self addSongToLibrary:curPath fromSongsPathId:kUserSongsPath useCache:NO]) {
//			// Write cache file
//			[[SongsDirectoryCache sharedInstance] writeCatalogueCache];
//		}
//	}
}


#pragma mark -
#pragma mark Singleton stuff

+ (ThemeManager*)sharedInstance {
    @synchronized(self) {
        if (sharedThemeManagerDelegate == nil) {
            [[self alloc] init];
        }
    }
    return sharedThemeManagerDelegate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedThemeManagerDelegate	== nil) {
            sharedThemeManagerDelegate = [super allocWithZone:zone];
            return sharedThemeManagerDelegate;
        }
    }
	
    return nil;
}


- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
	// NOTHING
}

- (id)autorelease {
    return self;
}

@end
