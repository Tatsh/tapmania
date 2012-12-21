//
//  $Id$
//  AlignmentCommand.mm
//
//  Created by Alex Kremer on 26.10.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "AlignmentCommand.h"

@implementation AlignmentCommand

- (id)initWithArguments:(NSArray *)inArgs andInvocationObject:(NSObject *)inObj
{
    self = [super initWithArguments:inArgs andInvocationObject:inObj];
    if (!self)
        return nil;

    if ([inArgs count] != 1)
    {
        TMLog(@"Wrong argument count for command 'alignment'. abort.");
        return nil;
    }

    if ([inObj respondsToSelector:@selector(setAlignment:)])
    {
        [inObj performSelector:@selector(setAlignment:) withObject:[m_aArguments objectAtIndex:0]];
        return self;
    }

    return nil;
}

@end