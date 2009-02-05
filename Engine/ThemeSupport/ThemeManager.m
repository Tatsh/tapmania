//
//  ThemeManager.m
//  ThemeManager
//
//  Created by Alex Kremer on 03.02.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "ThemeManager.h"
#import "ThemeMetrics.h"

// This is a singleton class, see below
static ThemeManager *sharedThemeManagerDelegate = nil;

@interface ThemeManager (Private)
- (NSObject*) lookUpNode:(NSString*) key;
@end


@implementation ThemeManager

@synthesize m_aThemesList, m_sCurrentThemeName;

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	/* We must list all the themes and store them into the mThemesList array */
	m_aThemesList = [[NSMutableArray alloc] initWithCapacity:1];
	int i;	
	
	NSString* themesDir = [[NSBundle mainBundle] pathForResource:@"themes" ofType:nil];	
	NSLog(@"Point themes dir to '%@'!", themesDir);
	
	NSArray* themesDirContents = [[NSFileManager defaultManager] directoryContentsAtPath:themesDir];
		
	// Raise error if empty themes dir
	if([themesDirContents count] == 0) {
		NSLog(@"Oops! Themes dir is empty. This should never happen.");
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
	
	return self;
}

- (void) selectTheme:(NSString*) themeName {
	
	if([m_aThemesList containsObject:themeName]) {
		m_sCurrentThemeName = themeName;
		
		NSString* themesDir = [[NSBundle mainBundle] pathForResource:@"themes" ofType:nil];	
		NSString* filePath = [themesDir stringByAppendingFormat:@"/%@/Metrics.plist", m_sCurrentThemeName];
		
		if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {		
			m_pCurrentThemeMetrics = [[ThemeMetrics alloc] initWithContentsOfFile:filePath];
			NSLog(@"Metrics loaded for theme '%@'.", m_sCurrentThemeName);
		} else {
			NSLog(@"Couldn't load Metrics.plist file from the selected theme! This should not happen.");
			exit(127);
		}
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
