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

@implementation TMResource

@synthesize m_sResourceName, m_pResource;

- (id) initWithPath:(NSString*) path andItemName:(NSString*) itemName {
	self = [super init];
	if(!self)
		return nil;
	
	m_bIsLoaded = NO;
	m_oClass = [Texture2D class];
	m_nCols = m_nRows = 1;	// 1x1 texture by default
	
	m_sFileSystemPath = [[NSString alloc] initWithString:path];
	m_pResource = nil;
	
	BOOL loadOnStartup = NO;
	
	// Check whether we must load it right now
	if( [itemName hasPrefix:@"_"] ) {
		loadOnStartup = YES;
	}
	
	NSMutableArray* pathAsArray = (NSMutableArray*)[path componentsSeparatedByString:@"/"];
	[pathAsArray removeLastObject];
	NSString* pathToHoldingDir = [pathAsArray componentsJoinedByString:@"/"];
	
	NSString* componentName = [[itemName componentsSeparatedByString:@"."] objectAtIndex:0];
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
	}
	
	m_sResourceName = [[NSString alloc] initWithString:componentName];
	NSString* loaderFile = nil;
	
	// Check whether the loader file exists
	if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.loader", pathToHoldingDir, componentName]]) {
		loaderFile = [NSString stringWithFormat:@"%@/%@.loader", pathToHoldingDir, componentName];
	} else if(loadOnStartup && [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/_%@.loader", pathToHoldingDir, componentName]]){
		loaderFile = [NSString stringWithFormat:@"%@/_%@.loader", pathToHoldingDir, componentName];
	}
	
	if(loaderFile) {
		NSLog(@"Have a loader file for this one...");
		NSData* contents = [[NSFileManager defaultManager] contentsAtPath:loaderFile];
		NSString* className = [NSString stringWithCString:[contents bytes]];
		
		m_oClass = [[NSBundle mainBundle] classNamed:className];
	}
	
	// Now load it directly if loadOnStartup is set
	if(loadOnStartup) {
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
	if(m_bIsLoaded) {
		NSLog(@"Resource is already loaded. ignore.");
		return;
	}
	
	NSLog(@"Will try to load a resource for class '%@'...", [m_oClass className]);
	
	// For all framed classes
	if( m_oClass == [TMFramedTexture class] ) {
		m_pResource = [[m_oClass alloc] initWithImage:[UIImage imageWithContentsOfFile:m_sFileSystemPath] columns:m_nCols andRows:m_nRows];
		m_bIsLoaded = YES;
		
	} else if ( m_oClass == [Texture2D class] ) {
		NSLog(@"Loading from file '%@'.", m_sFileSystemPath);
		m_pResource = [[m_oClass alloc] initWithImage:[UIImage imageWithContentsOfFile:m_sFileSystemPath]];
		m_bIsLoaded = YES;		
	}
	
	if(m_bIsLoaded) {
		NSLog(@"RESOURCE [%@] is loaded!", [m_oClass className]);	
	} else {
		NSLog(@"Failed to load resource!");
	}
}

- (void) unLoadResource {
	if(m_pResource) {
		[m_pResource release];
		m_bIsLoaded = NO;
	} else {
		NSLog(@"Resource wasn't loaded.");
	}
}

@end
