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
	NSNumber* n = (NSNumber*)[m_pCurrentThemeMetrics objectForKey:metricKey];
	if(n) 
		return [n intValue];
	
	return 0; // Default value
}

- (float) floatMetric:(NSString*) metricKey {
	NSNumber* n = (NSNumber*)[m_pCurrentThemeMetrics objectForKey:metricKey];
	if(n) 
		return [n floatValue];
	
	return 0.0f; // Default value	
}

- (NSString*) stringMetric:(NSString*) metricKey {
	NSString* s = (NSString*)[m_pCurrentThemeMetrics objectForKey:metricKey];
	if(s) 
		return [s autorelease];
	
	return @"EMPTY"; // Default value
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
