//
//  $Id$
//  ResourcesLoader.m
//  TapMania
//
//  Created by Alex Kremer on 06.02.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "ResourcesLoader.h"
#import "TMResource.h"
#import "FontManager.h"


@interface ResourcesLoader (Private)
- (void) loadResourceFromPath:(NSString*) path intoNode:(NSDictionary*) node;
- (NSObject*) lookUpNode:(NSString*) key;
@end


@implementation ResourcesLoader

@synthesize m_idDelegate;

- (id) initWithPath:(NSString*) rootPath type:(TMResourceLoaderType)inType andDelegate:(id) delegate {
	self = [super init];
	if(!self)
		return nil;
	
	m_idDelegate = delegate;
	m_nType = inType;
	m_pRoot = [[NSMutableDictionary alloc] init];
	
	m_sRootPath = rootPath;
	TMLog(@"Loading resources from root path at '%@'!!!", m_sRootPath);
	[self loadResourceFromPath:m_sRootPath intoNode:m_pRoot];
	TMLog(@"Loaded resources.");
	
	return self;
}

- (void) dealloc {
    // TODO: 	[self unLoadAll];
	[m_pRoot release];
	
	[super dealloc];
}

- (TMResource*) getResource:(NSString*) path {
	NSObject* node = [self lookUpNode:path];
	
	if(node) {
		if([node isKindOfClass:[TMResource class]]) {
            
			if(!((TMResource*)node).isLoaded) {
				[(TMResource*)node loadResource];
			}
            
			// Should be loaded now if above code worked
			return (TMResource*)node;
		} else if([node isKindOfClass:[NSDictionary class]]) {
			NSException* ex = [NSException exceptionWithName:@"Can't get resources."
													  reason:[NSString stringWithFormat:@"The path is not a resource. it seems to be a directory: %@", path] userInfo:nil];
			@throw ex;
		}
	} else {
		// Resource is not available! it's just not existing in the current theme or something like that... we must return the default resource in this case
		// TODO !!!
	}
	
	return nil;
}

- (void) preLoad:(NSString*) path {
	NSObject* node = [self lookUpNode:path];
	if(!node) {
		NSException* ex = [NSException exceptionWithName:@"Can't load resources."
                                                  reason:[NSString stringWithFormat:@"The path is not loaded: %@", path] userInfo:nil];
		@throw ex;
	}
	
	// If it's a leaf
	if([node isKindOfClass:[TMResource class]]) {
		[(TMResource*)node loadResource];
		
	} else {
		// It's a directory. preload everything inside...
	}
}

- (void) preLoadAll {
}

- (void) unLoad:(NSString*) path {
	NSObject* node = [self lookUpNode:path];
	if(!node) {
		TMLog(@"The resources on path '%@' are not loaded...", path);
	}
	
	if([node isKindOfClass:[NSDictionary class]]) {
		// Release all sub elements
	} else {
		[node release];
	}
}

- (void) unLoadAll {
    //	[self unLoad:m_pRoot];
}

/* Private methods */
- (void) loadResourceFromPath:(NSString*) path intoNode:(NSDictionary*) node {
	NSArray* dirContents = [[NSFileManager defaultManager] directoryContentsAtPath:path];
	
	// List all files and dirs there
	int i;
	for(i = 0; i<[dirContents count]; i++) {
		NSString* itemName = [dirContents objectAtIndex:i];
		NSString* curPath = [path stringByAppendingPathComponent:itemName];
		
		BOOL isDirectory;
		
		if([[NSFileManager defaultManager] fileExistsAtPath:curPath isDirectory:&isDirectory]) {
			// is dir?
			if(isDirectory) {
                    TMLog(@"[+] Found directory: %@", itemName);
                    if([itemName isEqualToString:@"iPad"] ||
                       [itemName isEqualToString:@"iPadRetina"] ||
                       [itemName isEqualToString:@"iPhoneRetina"] ||
                       [itemName isEqualToString:@"iPhone5"])
                    {
                        TMLog(@"[+] Skip this directory. It's a special directory with resolution-perfect graphics.");
                        continue;
                    }
				
                    // Create new dictionary
                    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                    TMLog(@"Start loading into '%@'", itemName);
                    [self loadResourceFromPath:curPath intoNode:dict];
				
                    TMLog(@"------");
				
                    // Add that new dict node to the node specified in the arguments
                    [node setValue:dict forKey:itemName];
                    TMLog(@"Stop adding there");
				
			} else {
                    // file. check type
                    if( m_idDelegate != nil && [m_idDelegate resourceTypeSupported:itemName] ) {
                            TMLog(@"[Supported] %@", itemName);
					
                            if(m_nType == kResourceLoaderFonts && [[itemName lowercaseString] hasSuffix:@".xml"]) {
						
                                // Remove the xml suffix
                                itemName = [itemName substringToIndex:[itemName length]-4]; // 4 is '.xml' length
                                [[FontManager sharedInstance] loadFont:curPath andName:itemName];
                                continue;
						
                            }
					
                            if(m_nType == kResourceLoaderFonts && [[itemName lowercaseString] hasSuffix:@".redir"]) {
						
                                // A font redirect?
                                NSData* contents = [[NSFileManager defaultManager] contentsAtPath:curPath];
                                NSString* contentsString = [[NSString alloc] initWithData:contents encoding:NSASCIIStringEncoding];
                                NSString* resourceFileSystemPath = [contentsString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]   ;
                                NSString* redirectedItemName = [resourceFileSystemPath lastPathComponent];
                                
                                if([redirectedItemName hasSuffix:@".xml"]) {
                                    // Yes. a font redirect.
                                    itemName = [itemName substringToIndex:[itemName length]-6]; // 6 is '.redir' length
                                    redirectedItemName = [redirectedItemName substringToIndex:[redirectedItemName length]-4]; // 4 is '.xml' length
                                    TMLog(@"Add font redir: '%@'=>'%@'", itemName, redirectedItemName);
                                    
                                    [[FontManager sharedInstance] addRedirect:itemName to:redirectedItemName];
                                    
                                    continue;
                                }
						
                                [contentsString release];
                            }
                    
                        TMResource* resource = [[TMResource alloc] initWithPath:curPath type:m_nType andItemName:itemName];
                        
                        // Add that resource if is valid
                        if(resource) {
                            [node setValue:resource forKey:resource.componentName];
                            TMLog(@"Added it to current node at key = '%@'", resource.componentName);
                        }
                    }
                }
            }
        }
}

// This method is looking up the resource in the hierarchy
- (NSObject*) lookUpNode:(NSString*) key {
	
	// Key is of format: "SomeRootElement SomeInnerElement SomeEvenMoreInnerElement TheResource"
	NSArray* pathChunks = [key componentsSeparatedByString:@" "];
	
	NSObject* tmp = m_pRoot;
	int i;
	
	for(i=0; i<[pathChunks count]-1; ++i) {
		if(tmp != nil && [tmp isKindOfClass:[NSMutableDictionary class]]) {
			// Search next component
			tmp = [(NSMutableDictionary*)tmp objectForKey:[pathChunks objectAtIndex:i]];
		}
	}
	
	if(tmp != nil) {
		tmp = [[(NSMutableDictionary*)tmp objectForKey:[pathChunks lastObject]] retain];
	}
	
	return tmp;	// nil or not
}

@end
