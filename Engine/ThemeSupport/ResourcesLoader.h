//
//  ResourcesLoader.h
//  TapMania
//
//  Created by Alex Kremer on 06.02.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

/* 
 * This class will load all the .png resources. It will deal with resources using simple mapping rules.
 * All the rules are specified in the ResourcesLoader.spec file in the docs folder.
 * 
 * The good part is that we will create separate loaders for current theme and current noteskin.. all using this class.
 */
@interface ResourcesLoader : NSObject {
	NSDictionary*		m_pRoot;		// Root of the components path. Contains all resources.
	NSString*			m_sRootPath;	// The root path from which we load the resources
}

/* The constructor */
- (id) initWithPath:(NSString*) rootPath;

/* This methods will preload specified stuff */
- (void) preLoad:(NSString*) path;
- (void) preLoadAll;

/* This methods will release specified stuff */
- (void) unLoad:(NSString*) path;
- (void) unLoadAll;

@end
