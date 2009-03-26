//
//  FontManager.m
//  TapMania
//
//  Created by Alex Kremer on 25.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "FontManager.h"
#import "Font.h"

// This is a singleton class, see below
static FontManager *sharedFontManagerDelegate = nil;

@implementation FontManager

@synthesize m_pCurrentFontResources, m_pFonts;

- (id) init {
	self = [super init];
	if(!self) 
		return nil;
	
	m_pFonts = [[NSMutableDictionary alloc] initWithCapacity:256];
	
	return self;
}

// Used to load all fonts from the specified fonts dir (usually it's the themes/THEMENAME/Fonts dir)
- (void) loadFonts:(NSString*)fontDirPath {
	// Use resource loader to do the dirty job
	m_pCurrentFontResources = [[ResourcesLoader alloc] initWithPath:fontDirPath type:kResourceLoaderFonts andDelegate:self];
	
	// Now call load on all the fonts which are retrieved by the resources system
	int i;

	TMLog(@"Now it's time to load all fonts...");
	NSArray* values = [m_pFonts allValues];
	
	TMLog(@"We collected info about %d fonts.. loading them now...", [values count]);
	
	for(i=0; i<[values count]; ++i) {
		Font* font = [values objectAtIndex:i];		
		[font load];
	}
}

- (void) loadFont:(NSString*)fontPath andName:(NSString*)name {
	TMLog(@"Have a font plist file at '%@'...", fontPath);
	NSDictionary* config = [NSDictionary dictionaryWithContentsOfFile:fontPath];
	Font* font = [[Font alloc] initWithName:name andConfig:config];
	
	// Add font
	[m_pFonts setObject:font forKey:name];
	TMLog(@"Font with name '%@' is added..", name);
}

/* ResourcesLoaderSupport delegate work */
- (BOOL) resourceTypeSupported:(NSString*) itemName {
	// Fonts are in PNG textures
	if([[itemName lowercaseString] hasSuffix:@".png"]) { 
		return YES;
	}
	
	// Another way is redirection. .redir files therefore should also be accepted
	if([[itemName lowercaseString] hasSuffix:@".redir"]) {
		return YES;
	}
	
	// And the most important is to get the plist files (ini files for fonts)
	if([[itemName lowercaseString] hasSuffix:@".plist"]) {
		return YES;
	}
	
	// TODO: handle multipart fonts (like the japanese kanji one which has multiple textures and one ini file)
	
	return NO;		
}

#pragma mark Singleton stuff
+ (FontManager*)sharedInstance {
    @synchronized(self) {
        if (sharedFontManagerDelegate == nil) {
            [[self alloc] init];
        }
    }
    return sharedFontManagerDelegate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedFontManagerDelegate	== nil) {
            sharedFontManagerDelegate = [super allocWithZone:zone];
            return sharedFontManagerDelegate;
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
