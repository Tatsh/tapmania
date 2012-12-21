//
//  $Id$
//  PlaySoundEffectCommand.mm
//  TapMania
//
//  Created by Alex Kremer on 30.10.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "PlaySoundEffectCommand.h"
#import "TMSoundEngine.h"
#import "ThemeManager.h"

@implementation PlaySoundEffectCommand

- (id)initWithArguments:(NSArray *)inArgs andInvocationObject:(NSObject *)inObj
{
    self = [super initWithArguments:inArgs andInvocationObject:inObj];
    if (!self)
        return nil;

    if ([inArgs count] != 1)
    {
        TMLog(@"Wrong argument count for command 'playsoundeffect'. abort.");
        return nil;
    }

    return self;
}

- (BOOL)invokeOnObject:(NSObject *)inObj
{
    [super invokeOnObject:inObj];

    // Get the sound key
    NSString *value = (NSString *) [self getValueFromString:[m_aArguments objectAtIndex:0] withObject:inObj];

    if (value)
    {
        TMSound *effect = SOUND(value);
        if (effect)
        {
            [[TMSoundEngine sharedInstance] playEffect:effect];
            return YES;
        }
    }

    return NO;
}

@end
