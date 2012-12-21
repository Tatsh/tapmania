//
//  $Id$
//  FontSizeCommand.mm
//  TapMania
//
//  Created by Alex Kremer on 26.10.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "FontSizeCommand.h"

@implementation FontSizeCommand

- (id)initWithArguments:(NSArray *)inArgs andInvocationObject:(NSObject *)inObj
{
    self = [super initWithArguments:inArgs andInvocationObject:inObj];
    if (!self)
        return nil;

    if ([inArgs count] != 1)
    {
        TMLog(@"Wrong argument count for command 'fontsize'. abort.");
        return nil;
    }

    if ([inObj respondsToSelector:@selector(setFontSize:)])
    {
        [inObj performSelector:@selector(setFontSize:) withObject:(NSNumber *) [m_aArguments objectAtIndex:0]];
        return self;
    }

    return nil;
}
@end
