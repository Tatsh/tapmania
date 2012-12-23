//
//  $Id$
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

- (id)init
{
    self = [super init];
    if (!self)
        return nil;

    // Defaults
    m_pUserConfig = [[TMUserConfig alloc] init];

    return self;
}

- (void)loadUserConfig
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] > 0)
    {
        NSString *dir = [paths objectAtIndex:0];
        NSString *configFile = [dir stringByAppendingPathComponent:kUserConfigFile];

        // Check whether it exists or not
        if (![[NSFileManager defaultManager] isReadableFileAtPath:configFile])
        {
            TMLog(@"Config file is missing. create one...");
            [self writeUserConfig];
            return;
        }

        TMLog(@"User config file at: %@", configFile);
        m_pUserConfig = [[TMUserConfig alloc] initWithContentsOfFile:configFile];
        if ([m_pUserConfig check] != 0)
        {
            [self writeUserConfig];
        }

    } else
    {
        NSException *ex = [NSException exceptionWithName:@"DocumentsDirNotFound" reason:@"Documents directory couldn't be found!" userInfo:nil];
        @throw ex;
    }
}

- (void)writeUserConfig
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] > 0)
    {
        NSString *dir = [paths objectAtIndex:0];
        NSString *configFile = [dir stringByAppendingPathComponent:kUserConfigFile];

        TMLog(@"Found config file to write: %@", configFile);
        [m_pUserConfig writeToFile:configFile atomically:NO];

    } else
    {
        NSException *ex = [NSException exceptionWithName:@"DocumentsDirNotFound" reason:@"Documents directory couldn't be found!" userInfo:nil];
        @throw ex;
    }
}

// Get values from user config
- (NSString *)getStringValue:(NSString *)key
{
    TMLog(@"Get value for key from config: '%@'", key);
    if ([m_pUserConfig valueForKey:key] != nil)
    {
        return (NSString *) [m_pUserConfig valueForKey:key];
    }

    return @"";
}

- (NSObject *)getObjectValue:(NSString *)key
{
    if ([m_pUserConfig valueForKey:key] != nil)
    {
        return [m_pUserConfig valueForKey:key];
    }

    return nil;
}

- (int)getIntValue:(NSString *)key
{
    if ([m_pUserConfig valueForKey:key] != nil)
    {
        return [(NSNumber *) [m_pUserConfig valueForKey:key] intValue];
    }

    return 0;
}

- (float)getFloatValue:(NSString *)key
{
    if ([m_pUserConfig valueForKey:key] != nil)
    {
        return [(NSNumber *) [m_pUserConfig valueForKey:key] floatValue];
    }

    return 0.0f;
}


- (double)getDoubleValue:(NSString *)key
{
    if ([m_pUserConfig valueForKey:key] != nil)
    {
        return [(NSNumber *) [m_pUserConfig valueForKey:key] doubleValue];
    }

    return 0.0;
}

- (BOOL)getBoolValue:(NSString *)key
{
    if ([m_pUserConfig valueForKey:key] != nil)
    {
        return [(NSNumber *) [m_pUserConfig valueForKey:key] boolValue];
    }

    return NO;
}

- (CGPoint)getJoyPadButton:(JPButton)button
{
    if ([m_pUserConfig valueForKey:@"joypad"] != nil)
    {
        NSArray *joyPadArr = [m_pUserConfig valueForKey:@"joypad"];

        if ([joyPadArr count] > button)
        {
            NSArray *buttonArr = [joyPadArr objectAtIndex:button];

            if (buttonArr != nil)
            {
                float x = [(NSNumber *) [buttonArr objectAtIndex:0] floatValue];
                float y = [(NSNumber *) [buttonArr objectAtIndex:1] floatValue];

                return CGPointMake(x, y);
            }
        }

        return CGPointMake(-1, -1);
    }

    return CGPointMake(-1, -1);
}

- (void)setValueFromObject:(NSObject *)value forKey:(NSString *)key
{
    [m_pUserConfig setObject:value forKey:key];
    [self writeUserConfig];
}

- (void)setStringValue:(NSString *)value forKey:(NSString *)key
{
    [m_pUserConfig setObject:value forKey:key];
    [self writeUserConfig];
}

- (void)setFloatValue:(float)value forKey:(NSString *)key
{
    [m_pUserConfig setObject:[NSNumber numberWithFloat:value] forKey:key];
    [self writeUserConfig];
}

- (void)setDoubleValue:(double)value forKey:(NSString *)key
{
    [m_pUserConfig setObject:[NSNumber numberWithDouble:value] forKey:key];
    [self writeUserConfig];
}

- (void)setIntValue:(int)value forKey:(NSString *)key
{
    [m_pUserConfig setObject:[NSNumber numberWithInt:value] forKey:key];
    [self writeUserConfig];
}

- (void)setBoolValue:(BOOL)value forKey:(NSString *)key
{
    [m_pUserConfig setObject:[NSNumber numberWithBool:value] forKey:key];
    [self writeUserConfig];
}

- (void)setJoyPadButtonPosition:(CGPoint)point forButton:(JPButton)button
{
    if ([m_pUserConfig valueForKey:@"joypad"] == nil)
    {
        [m_pUserConfig setObject:[[NSMutableArray alloc] initWithCapacity:kNumJoyButtons] forKey:@"joypad"];
    }

    NSMutableArray *joyPadArr = [m_pUserConfig valueForKey:@"joypad"];
    NSMutableArray *buttonArr = [[NSMutableArray alloc] initWithObjects:
            [NSNumber numberWithFloat:point.x], [NSNumber numberWithFloat:point.y], nil];

    if ([joyPadArr count] > button)
    {
        [joyPadArr replaceObjectAtIndex:button withObject:buttonArr];
    } else
    {
        [joyPadArr insertObject:buttonArr atIndex:button];
    }

    [self writeUserConfig];
}

#pragma mark Singleton stuff

+ (SettingsEngine *)sharedInstance
{
    @synchronized (self)
    {
        if (sharedSettingsEngineDelegate == nil)
        {
            [[self alloc] init];
        }
    }
    return sharedSettingsEngineDelegate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized (self)
    {
        if (sharedSettingsEngineDelegate == nil)
        {
            sharedSettingsEngineDelegate = [super allocWithZone:zone];
            return sharedSettingsEngineDelegate;
        }
    }

    return nil;
}


- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release
{
    // NOTHING
}

- (id)autorelease
{
    return self;
}

@end
