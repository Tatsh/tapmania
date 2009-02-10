//
//  ThemeManager.m
//  ThemeManager
//
//  Created by Alex Kremer on 03.02.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "ThemeManager.h"
#import "ThemeMetrics.h"
#import "ResourcesLoader.h"

#import <syslog.h>

// This is a singleton class, see below
static ThemeManager *sharedThemeManagerDelegate = nil;

@interface ThemeManager (Private)
- (NSObject*) lookUpNode:(NSString*) key;
@end


@implementation ThemeManager

@synthesize m_aThemesList, m_sCurrentThemeName, m_aNoteskinsList, m_sCurrentNoteskinName;
@synthesize m_pCurrentThemeResources, m_pCurrentNoteSkinResources;

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	/* We must list all the themes and store them into the mThemesList array */
	m_aThemesList = [[NSMutableArray alloc] initWithCapacity:1];
	m_aNoteskinsList = [[NSMutableArray alloc] initWithCapacity:1];
	int i;	
	
	NSString* themesDir = [[NSBundle mainBundle] pathForResource:@"themes" ofType:nil];	
	NSLog(@"Point themes dir to '%@'!", themesDir);

	NSString* noteskinsDir = [[NSBundle mainBundle] pathForResource:@"noteskins" ofType:nil];	
	NSLog(@"Point noteskins dir to '%@'!", noteskinsDir);
	
	NSArray* themesDirContents = [[NSFileManager defaultManager] directoryContentsAtPath:themesDir];
	NSArray* noteskinsDirContents = [[NSFileManager defaultManager] directoryContentsAtPath:noteskinsDir];
	
	// Raise error if empty themes dir
	if([themesDirContents count] == 0 || [noteskinsDirContents count] == 0) {
		NSLog(@"Oops! Themes dir or noteskins dir is empty. This should never happen."); // We should have the default themes always
		return nil;
	}
	
	// Iterate through the themes
	for(i = 0; i<[themesDirContents count]; i++) {		
		NSString* themeDirName = [themesDirContents objectAtIndex:i];
		NSString* path = [themesDir stringByAppendingFormat:@"/%@/Metrics.plist", themeDirName];
	
		// Check the Metrics.plist file
		if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
			// Ok. Looks like a valid tapmania theme.. add it to the list
			[m_aThemesList addObject:themeDirName];
			NSLog(@"Added theme '%@' to themes list.", themeDirName);
		}
	}

	// Iterate through the noteskins
	for(i = 0; i<[noteskinsDirContents count]; i++) {		
		NSString* noteskinDirName = [noteskinsDirContents objectAtIndex:i];
		NSString* path = [noteskinsDir stringByAppendingFormat:@"/%@/Metrics.plist", noteskinDirName];
		
		// Check the Metrics.plist file
		if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
			// Ok. Looks like a valid tapmania noteskin.. add it to the list
			[m_aNoteskinsList addObject:noteskinDirName];
			NSLog(@"Added noteskin '%@' to noteskins list.", noteskinDirName);
		}
	}
	
	return self;
}

- (void) selectTheme:(NSString*) themeName {
	
	if([m_aThemesList containsObject:themeName]) {
		m_sCurrentThemeName = themeName;
		
		NSString* themesDir = [[NSBundle mainBundle] pathForResource:@"themes" ofType:nil];	
		NSString* themeGraphicsPath = [themesDir stringByAppendingFormat:@"/%@/Graphics/", m_sCurrentThemeName];
		NSString* filePath = [themesDir stringByAppendingFormat:@"/%@/Metrics.plist", m_sCurrentThemeName];
		
		if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {		
			m_pCurrentThemeMetrics = [[ThemeMetrics alloc] initWithContentsOfFile:filePath];
			syslog(LOG_DEBUG, "metrics loaded from file %s", [filePath UTF8String]);
			m_pCurrentThemeResources = [[ResourcesLoader alloc] initWithPath:themeGraphicsPath andDelegate:self];
			
			syslog(LOG_DEBUG, "resources loaded from dir %s", [themeGraphicsPath UTF8String]);
			NSLog(@"Metrics and resources are loaded for theme '%@'.", m_sCurrentThemeName);
			
		} else {
			NSLog(@"Couldn't load Metrics.plist file from the selected theme! This should not happen.");
			exit(127);
		}
	}	
}

- (void) selectNoteskin:(NSString*) skinName {
	if([m_aNoteskinsList containsObject:skinName]) {
		m_sCurrentNoteskinName = skinName;		

		NSString* noteskinsDir = [[NSBundle mainBundle] pathForResource:@"noteskins" ofType:nil];	
		NSString* skinPath =	 [noteskinsDir stringByAppendingPathComponent:skinName];
		
		m_pCurrentNoteSkinResources = [[ResourcesLoader alloc] initWithPath:skinPath andDelegate:self];
	}		
}

- (int) intMetric:(NSString*) metricKey {
	NSObject* node = [self lookUpNode:metricKey];
	if(!node) 
		return 0; // Defualt value
	
	return [(NSNumber*)node	intValue];
}

- (float) floatMetric:(NSString*) metricKey {
	NSObject* node = [self lookUpNode:metricKey];
	if(!node) 
		return 0.0f; // Defualt value
	
	return [(NSNumber*)node	floatValue];
}

- (NSString*) stringMetric:(NSString*) metricKey {
	NSObject* node = [self lookUpNode:metricKey];
	if(!node) 
		return @"EMPTY"; // Defualt value
	
	return [[NSString stringWithString:(NSString*)node] autorelease];
}

- (Texture2D*) texture:(NSString*) textureKey {
	TMResource* resource = [m_pCurrentThemeResources getResource:textureKey];
	if(resource) {
		return (Texture2D*)[resource resource];
	}
	
	// TODO return some very default texture if not found
	return nil;
}

- (Texture2D*) skinTexture:(NSString*) textureKey {
	TMResource* resource = [m_pCurrentNoteSkinResources getResource:textureKey];
	if(resource) {
		return (Texture2D*)[resource resource];
	}
	
	// TODO return some very default texture if not found
	return nil;	
}

// This is the private method which searches through the metrics tree to get the metric
- (NSObject*) lookUpNode:(NSString*) key {
	
	// Key is of format: "SomeRootElement SomeInnerElement SomeEvenMoreInnerElement TheMetric"
	NSArray* pathChunks = [key componentsSeparatedByString:@" "];
	
	NSObject* tmp = m_pCurrentThemeMetrics;
	int i;
	
	for(i=0; i<[pathChunks count]-1; ++i) {
		if(tmp != nil && [tmp isKindOfClass:[NSDictionary class]]) {
			// Search next component
			tmp = [(NSDictionary*)tmp objectForKey:[pathChunks objectAtIndex:i]];
		}
	}
	
	if(tmp != nil) {
		tmp = [[(NSDictionary*)tmp objectForKey:[pathChunks lastObject]] retain];
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
	
	return NO;		
}

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
