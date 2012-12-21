//
//  $Id$
//  FontCommand.mm
//
//  Created by Alex Kremer on 26.10.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "FontCommand.h"

@implementation FontCommand

- (id)initWithArguments:(NSArray *)inArgs andInvocationObject:(NSObject *)inObj
{
    self = [super initWithArguments:inArgs andInvocationObject:inObj];
    if (!self)
        return nil;

    if ([inArgs count] != 1)
    {
        TMLog(@"Wrong argument count for command 'font'. abort.");
        return nil;
    }

    if ([inObj respondsToSelector:@selector(setFont:)])
    {
        [inObj performSelector:@selector(setFont:) withObject:[m_aArguments objectAtIndex:0]];
        return self;
    }

    return nil;
}

@end