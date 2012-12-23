//
//  $Id$
//  SettingsEngine.h
//  TapMania
//
//  Created by Alex Kremer on 13.05.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "JoyPad.h"

#define CFG_BOOL(key)    [[SettingsEngine sharedInstance] getBoolValue:key]
#define CFG_STR(key)    [[SettingsEngine sharedInstance] getStringValue:key]
#define CFG_INT(key)    [[SettingsEngine sharedInstance] getIntValue:key]
#define CFG_FLOAT(key)    [[SettingsEngine sharedInstance] getFloatValue:key]
#define CFG_DOUBLE(key)    [[SettingsEngine sharedInstance] getDoubleValue:key]

@class TMUserConfig;
#define kUserConfigFile @"TapManiaConfig.plist"

@interface SettingsEngine : NSObject
{
    TMUserConfig *m_pUserConfig;            // Current user config instance
}

- (void)loadUserConfig;

- (void)writeUserConfig;

- (CGPoint)getJoyPadButton:(JPButton)button;

- (void)setJoyPadButtonPosition:(CGPoint)point forButton:(JPButton)button;

- (NSString *)getStringValue:(NSString *)key;

- (int)getIntValue:(NSString *)key;

- (float)getFloatValue:(NSString *)key;

- (double)getDoubleValue:(NSString *)key;

- (BOOL)getBoolValue:(NSString *)key;

- (NSObject *)getObjectValue:(NSString *)key;

- (void)setStringValue:(NSString *)value forKey:(NSString *)key;

- (void)setFloatValue:(float)value forKey:(NSString *)key;

- (void)setDoubleValue:(double)value forKey:(NSString *)key;

- (void)setIntValue:(int)value forKey:(NSString *)key;

- (void)setBoolValue:(BOOL)value forKey:(NSString *)key;

- (void)setValueFromObject:(NSObject *)value forKey:(NSString *)key;

+ (SettingsEngine *)sharedInstance;

@end
