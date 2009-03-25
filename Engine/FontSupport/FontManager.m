//
//  FontManager.m
//  TapMania
//
//  Created by Alex Kremer on 25.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "FontManager.h"

// This is a singleton class, see below
static FontManager *sharedFontManagerDelegate = nil;

@implementation FontManager

@synthesize m_pCurrentFontResources;

// Used to load all fonts from the specified fonts dir (usually it's the themes/THEMENAME/Fonts dir)
- (void) loadFonts:(NSString*)fontDirPath {
	// Use resource loader to do the dirty job
	m_pCurrentFontResources = [[ResourcesLoader alloc] initWithPath:fontDirPath type:kResourceLoaderFonts andDelegate:self];
}

// Used to draw text
- (void) printText:(NSString*)str startPoint:(CGPoint)point {
	
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
