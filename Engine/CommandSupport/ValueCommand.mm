//
//  $Id$
//  ValueCommand.m
//  TapMania
//
//  Created by Alex Kremer on 23.10.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "ValueCommand.h"

@implementation ValueCommand

- (id)initWithArguments:(NSArray *)inArgs andInvocationObject:(NSObject *)inObj
{
    self = [super initWithArguments:inArgs andInvocationObject:inObj];
    if (!self)
        return nil;

    if ([inArgs count] != 1)
    {
        TMLog(@"Wrong argument count for command 'value'. abort.");
        return nil;
    }

    return self;
}

- (BOOL)invokeAtConstructionOnObject:(NSObject *)inObj
{
    if ([inObj respondsToSelector:@selector(setValue:)])
    {

        NSObject *value = [self getValueFromString:[m_aArguments objectAtIndex:0] withObject:inObj];

        if (value)
        {
            [inObj performSelector:@selector(setValue:) withObject:value];
            return YES;
        }
    }

    return NO;
}

@end
