//
//  TMNote.m
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMNote.h"


@implementation TMNote

@synthesize beat, tillBeat, type, beatType, isHit, hitTime, index;

- (id) initWithBeat:(float) lBeat andType:(TMNoteType)lType {
	self = [super init];
	if(!self)
		return nil;
	
	beat = lBeat;
	tillBeat = -1.0f;
	beatType = [TMNote getBeatType:[TMNote beatToNoteRow:lBeat]];
	type = lType;
	
	isHit = NO;
	hitTime = 0.0f;
	
	return self;
}

- (void) hit:(double)lHitTime {
	if(!isHit){
		isHit = YES;
		hitTime = lHitTime;
	}
}

+ (TMBeatType) getBeatType:(int) row {
	if(row % (kRowsPerMeasure/4) == 0)	return kBeatType_4th;
	if(row % (kRowsPerMeasure/8) == 0)	return kBeatType_8th;
	if(row % (kRowsPerMeasure/12) == 0)	return kBeatType_12th;
	if(row % (kRowsPerMeasure/16) == 0)	return kBeatType_16th;
	if(row % (kRowsPerMeasure/24) == 0)	return kBeatType_24th;
	if(row % (kRowsPerMeasure/32) == 0)	return kBeatType_32nd;
	if(row % (kRowsPerMeasure/48) == 0)	return kBeatType_48th;
	if(row % (kRowsPerMeasure/64) == 0)	return kBeatType_64th;
	return kBeatType_192nd;
}

+ (TMBeatType) beatToBeatType:(float) fBeat {
	return [TMNote getBeatType:[TMNote beatToNoteRow:fBeat]];
}

+ (int) beatToNoteRow:(float) fBeat {
	return lrintf( fBeat * kRowsPerBeat );	
}

@end
