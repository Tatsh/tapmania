//
//  $Id$
//  FontCharAliases.m
//  TapMania
//
//  Created by Alex Kremer on 31.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "FontCharAliases.h"
#import "Font.h"

// This is a singleton class, see below
static FontCharAliases *sharedCharAliasesDelegate = nil;

@implementation FontCharAliases

- (id)init
{
    self = [super init];
    if (!self)
        return nil;

    NSArray *objs = [NSArray arrayWithObjects:
            [NSString stringWithFormat:@"%C", DEFAULT_GLYPH],    // default
            [NSString stringWithFormat:@"%C", INVALID_CHAR],    // invalid
            nil];

    NSArray *keys = [NSArray arrayWithObjects:
            @"default",
            @"invalid",
            nil];

    m_pCharAliases = [[NSDictionary alloc]
            initWithObjects:objs forKeys:keys];

    return self;
}

- (void)replaceAll:(NSString *)text
{
    // Find the &ALIAS;
    int i, start, end;
    BOOL bInside;

    unichar alias[256];
    int aliasPos = 0;

    for (i = 0; i < [text length]; ++i)
    {
        unichar c = [text characterAtIndex:i];

        // Every time we hit '&' we know that we must start over
        if (c == '&')
        {
            bInside = YES;
            aliasPos = 0;
            start = i;

            continue;
        }

        if (c == ';' && bInside)
        {
            bInside = NO;
            alias[aliasPos++] = 0;
            end = i + 1;

            TMLog(@"Found alias = '%@'", [NSString stringWithCharacters:alias length:aliasPos]);
            unichar code;
            BOOL res = [self getChar:[NSString stringWithCharacters:alias length:aliasPos] result:&code];
            if (!res)
                [self getChar:@"default" result:&code];

            NSString *part1 = [text substringToIndex:start];
            NSString *part2 = [text substringFromIndex:end];

            text = [NSString stringWithFormat:@"%@%C%@", part1, code, part2];
            return [self replaceAll:text];    // Recursively replace everything
        }

        // store position
        if (bInside)
        {
            if (aliasPos >= 255)
            {
                bInside = NO;    // Too large alias. can't be
            } else
            {
                alias[aliasPos++] = c;
            }
        }
    }
}

- (BOOL)getChar:(NSString *)alias result:(unichar *)res
{
    NSString *code = [m_pCharAliases objectForKey:alias];

    if (code)
    {
        *res = [code characterAtIndex:0];
        return YES;
    }

    return NO;
}


#pragma mark Singleton stuff
+ (FontCharAliases *)sharedInstance
{
    @synchronized (self)
    {
        if (sharedCharAliasesDelegate == nil)
        {
            [[self alloc] init];
        }
    }
    return sharedCharAliasesDelegate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized (self)
    {
        if (sharedCharAliasesDelegate == nil)
        {
            sharedCharAliasesDelegate = [super allocWithZone:zone];
            return sharedCharAliasesDelegate;
        }
    }

    return nil;
}


- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release
{
    // NOTHING
}

- (id)autorelease
{
    return self;
}


@end
