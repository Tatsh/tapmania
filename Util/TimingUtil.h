//
//  TimingUtil.h
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TimingUtil : NSObject {
}

+ (double) getCurrentTime;
+ (double) getTimeInBeat:(float) bpm;

@end
