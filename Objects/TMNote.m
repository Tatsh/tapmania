//
//  TMNote.m
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMNote.h"


@implementation TMNote

@synthesize beat, tillBeat, type, isHit, hitTime;

- (id) initWithBeat:(float) lBeat tillBeat:(float) lTillBeat {
	self = [super init];
	if(!self)
		return nil;
	
	beat = lBeat;
	tillBeat = lTillBeat;
	type = [TMNote getNoteType:[TMNote beatToNoteRow:lBeat]];
	
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

+ (TMNoteType) getNoteType:(int) row {
	if(row % (kRowsPerMeasure/4) == 0)	return kNoteType_4th;
	if(row % (kRowsPerMeasure/8) == 0)	return kNoteType_8th;
	if(row % (kRowsPerMeasure/12) == 0)	return kNoteType_12th;
	if(row % (kRowsPerMeasure/16) == 0)	return kNoteType_16th;
	if(row % (kRowsPerMeasure/24) == 0)	return kNoteType_24th;
	if(row % (kRowsPerMeasure/32) == 0)	return kNoteType_32nd;
	if(row % (kRowsPerMeasure/48) == 0)	return kNoteType_48th;
	if(row % (kRowsPerMeasure/64) == 0)	return kNoteType_64th;
	return kNoteType_192nd;
}

+ (TMNoteType) beatToNoteType:(float) fBeat {
	return [TMNote getNoteType:[TMNote beatToNoteRow:fBeat]];
}

+ (int) beatToNoteRow:(float) fBeat {
	return lrintf( fBeat * kRowsPerBeat );	
}

@end
