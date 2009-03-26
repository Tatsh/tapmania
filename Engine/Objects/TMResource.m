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

@interface TMResource (Private)
- (void) parseDimensions:(NSString*)str;
@end


@implementation TMResource

@synthesize m_sResourceName, m_bIsLoaded, m_bIsSystem;
@dynamic m_pResource;

- (NSObject*) resource {
	if(m_bIsRedirect)
		return [m_pRedirectedResource resource];
	
	return m_pResource;
}

- (id) initWithPath:(NSString*) path type:(TMResourceLoaderType)inType andItemName:(NSString*) itemName {
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
		TMLog(@"REDIR FILE!");
		
		NSData* contents = [[NSFileManager defaultManager] contentsAtPath:m_sFileSystemPath];	
		NSString* contentsString = [[NSString alloc] initWithData:contents encoding:NSASCIIStringEncoding];
		NSString* resourceFileSystemPath = [contentsString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSString* redirectedItemName = [resourceFileSystemPath lastPathComponent]; 

		NSString* pathToHoldingDir = [[path stringByDeletingLastPathComponent]
												stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		resourceFileSystemPath = [pathToHoldingDir stringByAppendingPathComponent:resourceFileSystemPath];
		
		TMResource* redirectedResource = [[TMResource alloc] initWithPath:resourceFileSystemPath type:inType andItemName:redirectedItemName];

		m_pRedirectedResource = redirectedResource;
		m_bIsRedirect = YES;
		
		[contentsString release];
	}
		
	NSString* pathToHoldingDir = [path stringByDeletingLastPathComponent]; 	
	NSString* componentName = [itemName stringByDeletingPathExtension];	
	if( [componentName hasPrefix:@"_"] ) {
		componentName = [componentName substringFromIndex:1];	// Remove it from there
	}
	
	NSArray* nameSpecificator = [componentName componentsSeparatedByString:@"_"];
	
	// 1) ItemName_[PageName]_DxD.ext
	// 2) ItemName_[PageName].ext
	// 3) ItemName_DxD.ext
	// 4) ItemName.ext
	if( [nameSpecificator count] == 3 ) {		
		// Got a page and dimension
		NSString* pageName = [nameSpecificator objectAtIndex:1];
		NSString* dimensions = [nameSpecificator objectAtIndex:2];
	
		[self parseDimensions:dimensions];

		componentName = [NSString stringWithFormat:@"%@%@", [nameSpecificator objectAtIndex:0], pageName];
		
	} else if( [nameSpecificator count] == 2 ) {
		// Tricky! can have only page name or only dimension
	
		NSString* unknown = [nameSpecificator objectAtIndex:1];
		if(![unknown hasPrefix:@"["]) {
			// Dimension
			[self parseDimensions:unknown];
			
			componentName = [nameSpecificator objectAtIndex:0];
		} else {
			componentName = [NSString stringWithFormat:@"%@%@", [nameSpecificator objectAtIndex:0], unknown];
		}
				
		// Set class to framed texture
		m_oClass = [TMFramedTexture class];
	}
	
	m_sResourceName = [[NSString alloc] initWithString:componentName];
	NSString* loaderFile = nil;
	
	// Override stuff TODO
	if(inType == kResourceLoaderSounds) {
		// TODO: set default sound loader 
	}
	
	// Check whether the loader file exists
	if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.loader", pathToHoldingDir, componentName]]) {
		loaderFile = [NSString stringWithFormat:@"%@/%@.loader", pathToHoldingDir, componentName];
	} else if(m_bIsSystem && [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/_%@.loader", pathToHoldingDir, componentName]]){
		loaderFile = [NSString stringWithFormat:@"%@/_%@.loader", pathToHoldingDir, componentName];
	}
	
	if(loaderFile) {
		TMLog(@"Have a loader file for this one...");
		NSData* contents = [[NSFileManager defaultManager] contentsAtPath:loaderFile];
		NSString* className = [[NSString alloc] initWithData:contents encoding:NSASCIIStringEncoding];
		
		// Override loader class from loader file
		m_oClass = [[NSBundle mainBundle] classNamed:[className stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];		
		[className release];
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
		TMLog(@"Resource is already loaded. ignore.");
		return;
	}
	
	if(m_pResource = [[m_oClass alloc] initWithImage:[UIImage imageWithContentsOfFile:m_sFileSystemPath] columns:m_nCols andRows:m_nRows]) {
		m_bIsLoaded = YES;
	}
	
	if(!m_bIsLoaded) {
		TMLog(@"Failed to load resource!");
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
		TMLog(@"Resource wasn't loaded.");
	}
}

// Private
- (void) parseDimensions:(NSString*)str {
	NSArray* dimensionsArray = [str componentsSeparatedByString:@"x"];
	
	m_nCols = [[dimensionsArray objectAtIndex:0] intValue];
	m_nRows = [[dimensionsArray objectAtIndex:1] intValue];	
}

@end
