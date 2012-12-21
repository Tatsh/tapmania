//
//  $Id$
//  VolumeCommand.mm
//  TapMania
//
//  Created by Alex Kremer on 23.10.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "VolumeCommand.h"
#import "TMSoundEngine.h"

@implementation VolumeCommand

- (id)initWithArguments:(NSArray *)inArgs andInvocationObject:(NSObject *)inObj
{
    self = [super initWithArguments:inArgs andInvocationObject:inObj];
    if (!self)
        return nil;

    if ([inArgs count] != 2)
    {
        TMLog(@"Wrong argument count for command 'volume'. abort.");
        return nil;
    }

    return self;
}

- (BOOL)invokeOnObject:(NSObject *)inObj
{
    [super invokeOnObject:inObj];

    // Get sound source (effects or music)
    NSString *source = [self getValueFromString:[m_aArguments objectAtIndex:0] withObject:inObj];

    // Get new value to set
    NSObject *value = [self getValueFromString:[m_aArguments objectAtIndex:1] withObject:inObj];

    if (value && source)
    {
        if ([source isEqualToString:@"effects"])
        {
            [[TMSoundEngine sharedInstance] setEffectsVolume:[(NSNumber *) value floatValue]];
        } else if ([source isEqualToString:@"music"])
        {
            [[TMSoundEngine sharedInstance] setMasterVolume:[(NSNumber *) value floatValue]];
        }

        return YES;
    }

    return NO;
}

@end
