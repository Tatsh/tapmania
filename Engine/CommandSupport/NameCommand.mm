//
//  $Id$
//  NameCommand.mm
//  TapMania
//
//  Created by Alex Kremer on 9/20/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "NameCommand.h"

@implementation NameCommand

- (id)initWithArguments:(NSArray *)inArgs andInvocationObject:(NSObject *)inObj
{
    self = [super initWithArguments:inArgs andInvocationObject:inObj];
    if (!self)
        return nil;

    if ([inArgs count] != 1)
    {
        TMLog(@"Wrong argument count for command 'name'. abort.");
        return nil;
    }

    if ([inObj respondsToSelector:@selector(setName:)])
    {
        return self;
    }

    return self;
}

- (BOOL)invokeAtConstructionOnObject:(NSObject *)inObj
{
    [inObj performSelector:@selector(setName:) withObject:[m_aArguments objectAtIndex:0]];
    return YES;
}


@end
