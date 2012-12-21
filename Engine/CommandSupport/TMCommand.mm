//
//  $Id$
//  TMCommand.mm
//  TapMania
//
//  Created by Alex Kremer on 9/20/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMCommand.h"
#import "TapMania.h"
#import "SettingsEngine.h"

@implementation TMCommand

- (id)initWithArguments:(NSArray *)inArgs andInvocationObject:(NSObject *)inObj
{
    self = [super init];
    if (!self)
        return nil;

    m_aArguments = [inArgs copy];
    m_pInvocationObject = inObj;
    m_pNextCmd = nil;        // No next command by default

    return self;
}

- (void)dealloc
{
    TMLog(@"Release command object");

    [m_aArguments release];
    if (m_pNextCmd)
        [m_pNextCmd release];

    [super dealloc];
}

- (BOOL)invokeAtConstructionOnObject:(NSObject *)inObj
{
    return NO;
}

- (BOOL)invokeOnObject:(NSObject *)inObj
{
    if (m_pNextCmd)
    {
        // Must put it onto the runloop
        [m_pNextCmd setInvocationObject:inObj];
        [[TapMania sharedInstance] registerObjectAtEnd:m_pNextCmd];
    }
    return YES;
}

- (NSObject *)getValueFromString:(NSString *)str withObject:(NSObject *)inObj
{

    if ([str hasPrefix:@"{setting:"])
    {
        NSString *tmp = [str stringByReplacingOccurrencesOfString:@"{setting:" withString:@""];
        tmp = [tmp stringByReplacingOccurrencesOfString:@"}" withString:@""];

        return [[SettingsEngine sharedInstance] getObjectValue:tmp];
    }
    else if ([str isEqualToString:@"{value}"])
    {
        if ([inObj respondsToSelector:@selector(currentValue)])
        {
            return [inObj performSelector:@selector(currentValue)];
        } else
        {
            TMLog(@"CurrentValue method not supported by this object: %@", inObj);
            return nil;
        }
    }
    else
    {
        if ([@"YES" isEqualToString:[str uppercaseString]] || [@"NO" isEqualToString:[str uppercaseString]])
        {
            return [NSNumber numberWithBool:[str boolValue]];
        }

        return str;
    }
}

- (void)setInvocationObject:(NSObject *)inObj
{
    m_pInvocationObject = inObj;
}

- (NSObject *)getInvocationObject
{
    return m_pInvocationObject;
}

- (void)setNextCommand:(TMCommand *)inCmd
{
    m_pNextCmd = inCmd;
}

/* TMLogicUpdater stuff */
- (void)update:(float)fDelta
{
    // The simplest case is actually invoke the command and finish in one iteration
    [self invokeOnObject:m_pInvocationObject];

    // FIXME: release?
    [[TapMania sharedInstance] deregisterObject:self];
}

/* TMRenderable stuff */
- (void)render:(float)fDelta
{
}

- (id)copyWithZone:(NSZone *)zone
{
    TMCommand *cmd = [[[self class] alloc] initWithArguments:m_aArguments andInvocationObject:m_pInvocationObject];
    if (m_pNextCmd != nil)
    {
        // Make copy too
        [cmd setNextCommand:[m_pNextCmd copy]];
    }

    return cmd;
}


@end
