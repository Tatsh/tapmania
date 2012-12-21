//
//  $Id$
//  ScreenCommand.mm
//  TapMania
//
//  Created by Alex Kremer on 21.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "ScreenCommand.h"
#import "TMScreen.h"
#import "ThemeManager.h"
#import "TapMania.h"

@implementation ScreenCommand

- (id)initWithArguments:(NSArray *)inArgs andInvocationObject:(NSObject *)inObj
{
    self = [super initWithArguments:inArgs andInvocationObject:inObj];
    if (!self)
        return nil;

    if ([inArgs count] != 1)
    {
        TMLog(@"Wrong argument count for command 'screen'. abort.");
        return nil;
    }

    return self;
}

- (BOOL)invokeOnObject:(NSObject *)inObj
{
    [super invokeOnObject:inObj];

    // Get the screen name to switch
    NSString *screenName = [self getValueFromString:[m_aArguments objectAtIndex:0] withObject:inObj];

    // Every screen has a root metric dictionary in the root of the theme metrics
    // So just get that metric dictionary. The screen class is called $SCREENNAME+Renderer
    // If the screen class is not found will use TMScreen as the default one
    // It can also happen that the screen class is defined in the Class atribute of the metrics dict.

    NSDictionary *screenMetrics = DICT_METRIC(screenName);
    if (!screenMetrics)
    {
        TMLog(@"Invalid screen. Metrics for '%@' not found!", screenName);
        return NO;
    }

    Class cls;

    NSString *screenClass = [screenMetrics objectForKey:@"Class"];
    if (screenClass != nil)
    {
        screenClass = [screenClass stringByAppendingString:@"Renderer"];
        cls = [[NSBundle mainBundle] classNamed:screenClass];
    } else
    {
        // Try Name + Renderer
        screenClass = [screenName stringByAppendingString:@"Renderer"];
        cls = [[NSBundle mainBundle] classNamed:screenClass];
    }

    // If neither works. go for default
    if (!cls)
    {
        cls = [TMScreen class];
    }

    [[TapMania sharedInstance] switchToScreen:cls withMetrics:screenName];

    return YES;
}

@end
