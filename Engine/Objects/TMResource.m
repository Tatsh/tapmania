//
//  TMResource.m
//  TapMania
//
//  Created by Alex Kremer on 06.02.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "TMResource.h"
#import "Texture2D.h"
#import "TMFramedTexture.h"

#import <syslog.h>

@implementation TMResource

@synthesize m_sResourceName, m_bIsLoaded, m_bIsSystem;
@dynamic m_pResource;

- (NSObject*) resource {
	if(m_bIsRedirect)
		return [m_pRedirectedResource resource];
	
	return m_pResource;
}

- (id) initWithPath:(NSString*) path andItemName:(NSString*) itemName {
	self = [super init];
	if(!self)
		return nil;
	
	m_bIsLoaded = m_bIsSystem = m_bIsRedirect = NO;
	m_oClass = [Texture2D class];
	m_nCols = m_nRows = 1;	// 1x1 texture by default
	
	m_sFileSystemPath = [[NSString alloc] initWithString:path];
	m_pResource = nil;
	
	// Check whether we must load it right now
	if( [itemName hasPrefix:@"_"] ) {
		m_bIsSystem = YES;
	}
	
	// Check whether this is a redir file. It's a redir only when both the path and the key are with the redir suffix
	if( [itemName hasSuffix:@".redir"] && [m_sFileSystemPath hasSuffix:@".redir"] ) {
		NSLog(@"REDIR FILE!");
		
		NSData* contents = [[NSFileManager defaultManager] contentsAtPath:m_sFileSystemPath];
		NSLog(@"CONTENTS: '%s'", [contents bytes]);
		
		NSString* resourceFileSystemPath = [[NSString stringWithUTF8String:[contents bytes]] 
												stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

		NSLog(@"1: '%@'", resourceFileSystemPath);
		
		NSString* redirectedItemName = [resourceFileSystemPath lastPathComponent]; 
		NSLog(@"2: '%@'", redirectedItemName);
		
		NSString* pathToHoldingDir = [[path stringByDeletingLastPathComponent]
												stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSLog(@"3: '%@'", pathToHoldingDir);
		
		resourceFileSystemPath = [pathToHoldingDir stringByAppendingPathComponent:resourceFileSystemPath];
		
		NSLog(@"Redir path: '%@'", resourceFileSystemPath);
		NSLog(@"Redir item name: '%@'", redirectedItemName);
				
		TMResource* redirectedResource = [[TMResource alloc] initWithPath:resourceFileSystemPath andItemName:redirectedItemName];

		NSLog(@"Redirected resource created!");
		
		m_pRedirectedResource = redirectedResource;
		m_bIsRedirect = YES;
	}
		
	NSString* pathToHoldingDir = [path stringByDeletingLastPathComponent]; 	
	NSString* componentName = [itemName stringByDeletingPathExtension];	
	if( [componentName hasPrefix:@"_"] ) {
		componentName = [componentName substringFromIndex:1];	// Remove it from there
	}
	
	NSArray* nameAndDimension = [componentName componentsSeparatedByString:@"_"];
	
	// Try to get the _NxM suffix if it exists
	if( [nameAndDimension count] > 1 ) {
		NSString* dimensions = [nameAndDimension objectAtIndex:1];
		NSArray* dimensionsArray = [dimensions componentsSeparatedByString:@"x"];
		
		m_nCols = [[dimensionsArray objectAtIndex:0] intValue];
		m_nRows = [[dimensionsArray objectAtIndex:1] intValue];
		
		componentName = [nameAndDimension objectAtIndex:0];
		
		// Set class to framed texture
		m_oClass = [TMFramedTexture class];
	}
	
	m_sResourceName = [[NSString alloc] initWithString:componentName];
	NSString* loaderFile = nil;
	
	// Check whether the loader file exists
	if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.loader", pathToHoldingDir, componentName]]) {
		loaderFile = [NSString stringWithFormat:@"%@/%@.loader", pathToHoldingDir, componentName];
	} else if(m_bIsSystem && [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/_%@.loader", pathToHoldingDir, componentName]]){
		loaderFile = [NSString stringWithFormat:@"%@/_%@.loader", pathToHoldingDir, componentName];
	}
	
	if(loaderFile) {
		NSLog(@"Have a loader file for this one...");
		NSData* contents = [[NSFileManager defaultManager] contentsAtPath:loaderFile];
		NSString* className = [NSString stringWithUTF8String:[contents bytes]];
		
		// Override loader class from loader file
		m_oClass = [[NSBundle mainBundle] classNamed:className];
	}
	
	// Now load it directly if loadOnStartup is set
	if(m_bIsSystem) {
		[self loadResource];
	}
	
	return self;
}

- (void) dealloc {
	[m_sFileSystemPath release];
	[m_sResourceName release];
	
	if(m_pResource) {
		[m_pResource release];
	}
	
	[super dealloc];
}


- (void) loadResource {
	if(m_bIsRedirect) {
		return [m_pRedirectedResource loadResource];
	}
	
	if(m_bIsLoaded) {
		NSLog(@"Resource is already loaded. ignore.");
		syslog(LOG_DEBUG, "Resource already loaded. ignore");
		return;
	}
	
	// For all framed classes
	if( m_oClass == [TMFramedTexture class] ) {
		m_pResource = [[m_oClass alloc] initWithImage:[UIImage imageWithContentsOfFile:m_sFileSystemPath] columns:m_nCols andRows:m_nRows];
		m_bIsLoaded = YES;
		
	} else if ( m_oClass == [Texture2D class] ) {
		NSLog(@"Loading from file '%@'.", m_sFileSystemPath);
		m_pResource = [[m_oClass alloc] initWithImage:[UIImage imageWithContentsOfFile:m_sFileSystemPath]];
		m_bIsLoaded = YES;		
	}
	
	if(!m_bIsLoaded) {
		NSLog(@"Failed to load resource!");
	}
}

- (void) unLoadResource {
	if(m_bIsRedirect) {
		return [m_pRedirectedResource unLoadResource];
	}
	
	if(m_pResource) {
		[m_pResource release];
		m_bIsLoaded = NO;
	} else {
		NSLog(@"Resource wasn't loaded.");
	}
}

@end
