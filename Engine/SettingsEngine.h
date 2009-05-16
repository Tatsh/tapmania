//
//  SettingsEngine.h
//  TapMania
//
//  Created by Alex Kremer on 13.05.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMUserConfig;
#define kUserConfigFile @"TapManiaConfig.plist"

@interface SettingsEngine : NSObject {
	TMUserConfig*		m_pUserConfig;			// Current user config instance
}

- (void) loadUserConfig;
- (void) writeUserConfig;

- (NSString*) getStringValue:(NSString*)key;
- (int) getIntValue:(NSString*)key;
- (float) getFloatValue:(NSString*)key;

- (void) setStringValue:(NSString*)value forKey:(NSString*)key;
- (void) setFloatValue:(float)value forKey:(NSString*)key;

+ (SettingsEngine *) sharedInstance;

@end
