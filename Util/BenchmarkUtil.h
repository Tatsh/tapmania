//
//  $Id$
//  BenchmarkUtil.h
//  TapMania
//
//  Created by Alex Kremer on 29.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BenchmarkUtil : NSObject
{
    float m_fStartTime;
    float m_fFinishTime;
    NSString *m_sName;
}

+ (id)instanceWithName:(NSString *)name; // Used to get an instance and automatically start it

- (id)initWithName:(NSString *)name;

- (void)start;  // Start the benchmark
- (void)finish; // Finish the benchmark and automatically print latest stats

- (void)stats;    // Print current stats

@end
