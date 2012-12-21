//
//  $Id$
//  BenchmarkUtil.m
//  TapMania
//
//  Created by Alex Kremer on 29.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "BenchmarkUtil.h"
#import "TimingUtil.h"

@implementation BenchmarkUtil

+ (id)instanceWithName:(NSString *)name
{
    BenchmarkUtil *bm = [[BenchmarkUtil alloc] initWithName:name];
    [bm start];
    return [bm autorelease];
}

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (!self)
        return nil;

    m_sName = name;

    m_fStartTime = 0.0f;
    m_fFinishTime = 0.0f;

    return self;
}

- (void)start
{
    m_fStartTime = [TimingUtil getCurrentTime];
}

- (void)finish
{
    m_fFinishTime = [TimingUtil getCurrentTime];
    [self stats];
}

- (void)stats
{
    float delta = m_fFinishTime == 0.0f ? [TimingUtil getCurrentTime] : m_fFinishTime - m_fStartTime;
    TMLog(@"Benchmark [%s] elapsed time: %lf", [m_sName UTF8String], delta);
}

@end
