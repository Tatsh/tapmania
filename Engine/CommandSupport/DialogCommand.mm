//
//  $Id$
//  DialogCommand.mm
//  TapMania
//
//  Created by Alex Kremer on 03.09.10.
//  Copyright 2010 Godexsoft. All rights reserved.
//

#import "DialogCommand.h"
#import "TMModalView.h"
#import "ThemeManager.h"
#import "TapMania.h"

@implementation DialogCommand

- (id)initWithArguments:(NSArray *)inArgs andInvocationObject:(NSObject *)inObj
{
    self = [super initWithArguments:inArgs andInvocationObject:inObj];
    if (!self)
        return nil;

    if ([inArgs count] != 1)
    {
        TMLog(@"Wrong argument count for command 'dialog'. abort.");
        return nil;
    }

    return self;
}

- (BOOL)invokeOnObject:(NSObject *)inObj
{
    [super invokeOnObject:inObj];

    // Get the dialog name to raise
    NSString *dialogName = [self getValueFromString:[m_aArguments objectAtIndex:0] withObject:inObj];

    // Every dialog, just as every screen has a root metric dictionary in the root of the theme metrics
    // So just get that metric dictionary. The dialog class is called $DIALOGNAME+DialogRenderer
    // If the dialog class is not found will use TMModalView as the default one
    // It can also happen that the dialog class is defined in the Class atribute of the metrics dict.

    NSDictionary *dialogMetrics = DICT_METRIC(dialogName);
    if (!dialogMetrics)
    {
        TMLog(@"Invalid dialog. Metrics for '%@' not found!", dialogName);
        return NO;
    }

    Class cls;

    NSString *dialogClass = [dialogMetrics objectForKey:@"Class"];
    if (dialogClass != nil)
    {
        dialogClass = [dialogClass stringByAppendingString:@"DialogRenderer"];
        cls = [[NSBundle mainBundle] classNamed:dialogClass];
    } else
    {
        // Try Name + DialogRenderer
        dialogClass = [dialogName stringByAppendingString:@"DialogRenderer"];
        cls = [[NSBundle mainBundle] classNamed:dialogClass];
    }

    // If neither works. go for default
    if (!cls)
    {
        cls = [TMModalView class];
    }

    [[TapMania sharedInstance] addOverlay:cls withMetrics:dialogName];

    return YES;
}

@end
