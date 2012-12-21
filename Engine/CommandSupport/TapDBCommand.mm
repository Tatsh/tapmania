//
//  $Id$
//  TapDBCommand.mm
//  TapMania
//
//  Created by Alex Kremer on 18.08.10.
//  Copyright 2010 Godexsoft. All rights reserved.
//

#import "TMCommand.h"
#import "TapDBCommand.h"
#import "TapMania.h"

@implementation TapDBCommand

- (id)initWithArguments:(NSArray *)inArgs andInvocationObject:(NSObject *)inObj
{
    self = [super initWithArguments:inArgs andInvocationObject:inObj];
    if (!self)
        return nil;

    if ([inArgs count] != 0)
    {
        TMLog(@"Wrong argument count for command 'tapdb'. abort.");
        return nil;
    }

    return self;
}

- (BOOL)invokeOnObject:(NSObject *)inObj
{
    [super invokeOnObject:inObj];

    [[TapMania sharedInstance] switchToTapDB];

    return YES;
}

@end
