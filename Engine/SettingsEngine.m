//
//  SettingsEngine.m
//  TapMania
//
//  Created by Alex Kremer on 13.05.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "SettingsEngine.h"
#import "TMUserConfig.h"

// This is a singleton class, see below
static SettingsEngine *sharedSettingsEngineDelegate = nil;

@implementation SettingsEngine

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	// Defaults
	m_pUserConfig = [[TMUserConfig alloc] init];
	
	return self;
}

- (void) loadUserConfig {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	if([paths count] > 0) {
		NSString * dir = [paths objectAtIndex:0]; 
		NSString * configFile = [dir stringByAppendingPathComponent:kUserConfigFile];
	
		// Check whether it exists or not
		if(! [[NSFileManager defaultManager] isReadableFileAtPath:configFile]){
			TMLog(@"Config file is missing. create one...");
			[self writeUserConfig];
			return;
		}
		
		TMLog(@"User config file at: %@", configFile);		
		m_pUserConfig = [[TMUserConfig alloc] initWithContentsOfFile:configFile];		
		if( [m_pUserConfig check] != 0 ) {
			[self writeUserConfig];
		}
		
	} else {
		NSException *ex = [NSException exceptionWithName:@"DocumentsDirNotFound" reason:@"Documents directory couldn't be found!" userInfo:nil];
		@throw ex;
	}
}

- (void) writeUserConfig {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	if([paths count] > 0) {
		NSString * dir = [paths objectAtIndex:0]; 
		NSString * configFile = [dir stringByAppendingPathComponent:kUserConfigFile];
		
		TMLog(@"Found config file to write: %@", configFile);
		[m_pUserConfig writeToFile:configFile atomically:NO];
	
	} else {
		NSException *ex = [NSException exceptionWithName:@"DocumentsDirNotFound" reason:@"Documents directory couldn't be found!" userInfo:nil];
		@throw ex;
	}
}

// Get values from user config
- (NSString*) getStringValue:(NSString*)key {
	TMLog(@"Get value for key from config: '%@'", key);
	if( [m_pUserConfig valueForKey:key] != nil ) {
		return (NSString*)[m_pUserConfig valueForKey:key];
	}
	
	return @"";
}

- (int) getIntValue:(NSString*)key {
	if( [m_pUserConfig valueForKey:key] != nil ) {
		return [(NSNumber*)[m_pUserConfig valueForKey:key] intValue];
	}	
	
	return 0;
}

- (float) getFloatValue:(NSString*)key {
	if( [m_pUserConfig valueForKey:key] != nil ) {
		return [(NSNumber*)[m_pUserConfig valueForKey:key] floatValue];
	}	
	
	return 0.0f;
}


- (void) setStringValue:(NSString*)value forKey:(NSString*)key {
	[m_pUserConfig setObject:value forKey:key];
	[self writeUserConfig];
}

- (void) setFloatValue:(float)value forKey:(NSString*)key {
	[m_pUserConfig setObject:[NSNumber numberWithFloat:value] forKey:key];
	[self writeUserConfig];
}


#pragma mark Singleton stuff

+ (SettingsEngine*)sharedInstance {
    @synchronized(self) {
        if (sharedSettingsEngineDelegate == nil) {
            [[self alloc] init];
        }
    }
    return sharedSettingsEngineDelegate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedSettingsEngineDelegate	== nil) {
            sharedSettingsEngineDelegate = [super allocWithZone:zone];
            return sharedSettingsEngineDelegate;
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
