//
//  $Id$
//  SettingCommand.m
//  TapMania
//
//  Created by Alex Kremer on 23.10.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "SettingCommand.h"
#import "SettingsEngine.h"

@implementation SettingCommand

- (id)initWithArguments:(NSArray *)inArgs andInvocationObject:(NSObject *)inObj
{
    self = [super initWithArguments:inArgs andInvocationObject:inObj];
    if (!self)
        return nil;

    if ([inArgs count] != 2)
    {
        TMLog(@"Wrong argument count for command 'setting'. abort.");
        return nil;
    }

    return self;
}

- (BOOL)invokeOnObject:(NSObject *)inObj
{
    [super invokeOnObject:inObj];

    // Get the setting name to tune
    NSString *settingName = [self getValueFromString:[m_aArguments objectAtIndex:0] withObject:inObj];
    if (!settingName || ![settingName length])
    {
        return NO;
    }

    // Get new value to set
    NSObject *value = [self getValueFromString:[m_aArguments objectAtIndex:1] withObject:inObj];

    if (value)
    {
        [[SettingsEngine sharedInstance] setValueFromObject:value forKey:settingName];
        return YES;
    }

    return NO;
}

@end
