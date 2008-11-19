//
//  TimingUtil.m
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TimingUtil.h"

#include <mach/mach.h>
#include <mach/mach_time.h>

@implementation TimingUtil

+ (double) getCurrentTime {
	static mach_timebase_info_data_t sTimebaseInfo;
	uint64_t time = mach_absolute_time();
	uint64_t nanos;
	
	if( sTimebaseInfo.denom == 0 ) {
		(void) mach_timebase_info(&sTimebaseInfo);
	}
	
	nanos = time * sTimebaseInfo.numer / sTimebaseInfo.denom;
	return ((double)nanos / 1000000000.0);
}

+ (double) getTimeInBeatForBPS:(float) bps {
	/* 
		For example max300 would be:
		300 bpm = 5 beats per second which makes 0.2 sec. (200 ms.) == one beat.
	 */
	
	return 1.0/bps;
}

+ (float) getBpmAtBeat:(float) beat inSong:(TMSong*) song{
	int i;	
	for(i=0; i<[song.bpmChangeArray count]-1; i++){
		if( [(TMBeatBasedChange*)[song.bpmChangeArray objectAtIndex:i+1] beat] > beat){
			break;
		}
	}
	
	return [(TMBeatBasedChange*)[song.bpmChangeArray objectAtIndex:i] changeValue];
}

/*
	TODO: Search for the last beat which is still visible on the current screen frame
*/
+ (float) findLastBeatOnScreenFromElapsedTime:(double) elapsedTime currentBeat:(float) currentBeat currentBps:(float) currentBps inSong:(TMSong*) song {
	
	// timeDelta will hold the time for the last beat visible on screen
	double timeDelta = 0.0f;
	
	// Lookup the closest bpm change
	unsigned i;
	for( i=0; i<[song.bpmChangeArray count]-1; i++) { // Foreach bpm change in the song
		if ([(TMBeatBasedChange*)[song.bpmChangeArray objectAtIndex:i+1] beat] >= currentBeat) 
			break;
	}
	
	return 0.0f;
}

+ (void) getBeatAndBPSFromElapsedTime:(double) elapsedTime beatOut:(float*)beatOut bpsOut:(float*)bpsOut freezeOut:(BOOL*)freezeOut inSong:(TMSong*) song {

	elapsedTime += song.gap;
	
	unsigned i;
	for( i=0; i<[song.bpmChangeArray count]; i++) { // Foreach bpm change in the song
		
		const float startBeatThisChange = [(TMBeatBasedChange*)[song.bpmChangeArray objectAtIndex:i] beat]; 
		const BOOL isFirstBpmChange = i==0;
		const BOOL isLastBpmChange = i==[song.bpmChangeArray count]-1;
		const float startBeatNextChange = isLastBpmChange ? MAXFLOAT : [(TMBeatBasedChange*)[song.bpmChangeArray objectAtIndex:i+1] beat];
		const float bps = [(TMBeatBasedChange*)[song.bpmChangeArray objectAtIndex:i] changeValue] / 60.0f;
	
		unsigned j;
		for( j=0; j<[song.freezeArray count]; j++) { // Foreach freeze
			TMBeatBasedChange* freeze = [song.freezeArray objectAtIndex:j];
			
			if(!isFirstBpmChange && startBeatThisChange >= [freeze beat] )
				continue;
			if(!isLastBpmChange && [freeze beat] > startBeatNextChange )
				continue;
			
			const float beatsSinceStartOfChange = [freeze beat] - startBeatThisChange;
			const float freezeStartSecond = beatsSinceStartOfChange / bps;
			
			if( freezeStartSecond >= elapsedTime )
				break;
			
			// Apply the freeze
			elapsedTime -= [freeze changeValue]/1000.0f;
			
			if( freezeStartSecond >= elapsedTime ){
				// Lies within the stop
				*beatOut = [freeze beat];
				*bpsOut = bps;
				*freezeOut = YES;	// In freeze
				return;
			}
		}
		
		const float beatsInThisChangeSegment = startBeatNextChange - startBeatThisChange;
		const float secondsInThisChangeSegment = beatsInThisChangeSegment / bps;
		
		if( isLastBpmChange || elapsedTime <= secondsInThisChangeSegment ){
			// Is the current change segment
			*beatOut = startBeatThisChange + elapsedTime * bps;
			*bpsOut = bps;
			*freezeOut = NO;
			
			return;
		}
		
		// Not the current change segment
		elapsedTime -= secondsInThisChangeSegment;
		
	}
}

@end
