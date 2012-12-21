//
//  $Id$
//  Metrics.m
//  TapMania
//
//  Created by Alex Kremer on 03.02.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "Metrics.h"

@interface Metrics (Private)
+ (NSMutableDictionary *)overrideDictionary:(NSMutableDictionary *)to withDictionary:(NSMutableDictionary *)from;
@end

@implementation Metrics
@synthesize impl_;

- (id)initWithContentsOfFile:(NSString *)fp
{
    self = [super init];

    self.impl_ = [[NSMutableDictionary alloc] initWithContentsOfFile:fp];

    return self;
}

- (oneway void)release
{
    self.impl_ = nil;
    [super release];
}

- (void)overrideWith:(Metrics *)metrics
{
    self.impl_ = [Metrics overrideDictionary:impl_ withDictionary:metrics.impl_];
}

+ (NSMutableDictionary *)overrideDictionary:(NSMutableDictionary *)to withDictionary:(NSMutableDictionary *)from
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:[to count]];

    for (id k in [to allKeys])
    {
        NSObject *o = [to objectForKey:k];

        TMLog(@"--- Got key '%@'", [k description]);

        if ([o isKindOfClass:NSDictionary.class])
        {
            TMLog(@"--- is a Dictionary...");

            NSObject *ofk = [from objectForKey:k];
            if (ofk != nil)
            {
                [result setObject:[Metrics overrideDictionary:((NSMutableDictionary *) o) withDictionary:((NSMutableDictionary *) ofk)] forKey:k];
            }
            else
            {
                [result setObject:o forKey:k];
            }
        }
        else
        {
            TMLog(@"--- Another class: %@", o.class);

            NSObject *ofk = [from objectForKey:k];
            if (ofk != nil)
            {
                [result setObject:ofk forKey:k];
            }
            else
            {
                [result setObject:o forKey:k];
            }
        }
    }

    return result;
}

- (id)objectForKey:(id)key
{
    return [self.impl_ objectForKey:key];
}

@end
