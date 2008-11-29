//
//  BenchmarkUtil.h
//  TapMania
//
//  Created by Alex Kremer on 29.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BenchmarkUtil : NSObject {
	float startTime;
	float finishTime;
	NSString* name;
}

+ (id) instanceWithName:(NSString*)lName; // Used to get an instance and automatically start it

- (id) initWithName:(NSString*)lName;

- (void) start;  // Start the benchmark
- (void) finish; // Finish the benchmark and automatically print latest stats

- (void) stats;	// Print current stats

@end
