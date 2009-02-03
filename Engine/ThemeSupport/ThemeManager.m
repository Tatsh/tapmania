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

@synthesize mThemesList, mCurrentThemeName, mCurrentThemeMetrics;

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	/* We must list all the themes and store them into the mThemesList array */
	mThemesList = [[NSMutableArray alloc] initWithCapacity:1];
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
			[mThemesList addObject:themeDirName];
			NSLog(@"Added theme '%@' to themes list.", themeDirName);
		}
	}
	
	return self;
}

- (void) selectTheme:(NSString*) themeName {
	
	if([mThemesList containsObject:themeName]) {
		mCurrentThemeName = themeName;
		
		NSString* filePath = [NSString stringWithFormat:@"themes/%@/Metrics.plist", mCurrentThemeName];
		mCurrentThemeMetrics = [[ThemeMetrics alloc] initWithContentsOfFile:filePath];
		
		NSLog(@"Metrics loaded for theme '%@'.", mCurrentThemeName);
	}	
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
