//
//  TimingUtil.h
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMSong.h"
#import "TMChangeSegment.h"

@interface TimingUtil : NSObject {
}

+ (double) getCurrentTime;
+ (double) getTimeInBeatForBPS:(float) bps;
+ (float) getBpsAtBeat:(float) beat inSong:(TMSong*) song;
+ (float) getElapsedTimeFromBeat:(float) beat inSong:(TMSong*) song;
+ (int) getNextBpmChangeFromBeat:(float) beat inSong:(TMSong*) song;
+ (void) getBeatAndBPSFromElapsedTime:(double) elapsedTime beatOut:(float*)beatOut bpsOut:(float*)bpsOut freezeOut:(BOOL*)freezeOut inSong:(TMSong*) song;
+ (float) getPixelsPerNoteRowForBPS:(float) bps andSpeedMod:(float) sMod;

@end
