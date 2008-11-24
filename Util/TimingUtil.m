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

#define kFullScreenSize 380.0f

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
	int noteRow = [TMNote beatToNoteRow:beat];
	
	int i;	
	for(i=0; i<[song.bpmChangeArray count]-1; i++){
		if( [(TMChangeSegment*)[song.bpmChangeArray objectAtIndex:i+1] noteRow] > noteRow){
			break;
		}
	}
	
	return [(TMChangeSegment*)[song.bpmChangeArray objectAtIndex:i] changeValue];
}

+ (float) getElapsedTimeFromBeat:(float) beat inSong:(TMSong*) song {
	float elapsedTime = 0.0f;
	elapsedTime -= song.gap;
	
	int noteRow = [TMNote beatToNoteRow:beat];
	unsigned i;
	
	for(i=0; i<[song.freezeArray count]; i++){
		if([(TMChangeSegment*)[song.freezeArray objectAtIndex:i] noteRow] >= noteRow) {
			break;
		}
		
		elapsedTime += [(TMChangeSegment*)[song.freezeArray objectAtIndex:i] changeValue]/1000.0f;		
	}
	
	for(i=0; i<[song.bpmChangeArray count]; i++){
		const BOOL isLastBpmChange = i == [song.bpmChangeArray count]-1;
		const float bps = [(TMChangeSegment*)[song.bpmChangeArray objectAtIndex:i] changeValue] / 60.0f; 
		
		if(isLastBpmChange){
			elapsedTime += [TMNote noteRowToBeat:noteRow]/bps;
		} else {
			const int startRowThisChange = [(TMChangeSegment*)[song.bpmChangeArray objectAtIndex:i] noteRow]; 
			const int startRowNextChange = [(TMChangeSegment*)[song.bpmChangeArray objectAtIndex:i+1] noteRow];
			const int rowsInSegment = fminl( startRowNextChange - startRowThisChange, noteRow );
			elapsedTime += [TMNote noteRowToBeat:rowsInSegment]/bps;
			noteRow -= rowsInSegment;
		}
		
		if( noteRow <= 0 )
			return elapsedTime;
	}
	
	return elapsedTime;
}

+ (void) getBeatAndBPSFromElapsedTime:(double) elapsedTime beatOut:(float*)beatOut bpsOut:(float*)bpsOut freezeOut:(BOOL*)freezeOut inSong:(TMSong*) song {

	elapsedTime += song.gap;
	
	unsigned i;
	for( i=0; i<[song.bpmChangeArray count]; i++) { // Foreach bpm change in the song
		
		const int startRowThisChange = [(TMChangeSegment*)[song.bpmChangeArray objectAtIndex:i] noteRow]; 
		const float startBeatThisChange = [TMNote noteRowToBeat:startRowThisChange]; 
		const BOOL isFirstBpmChange = i==0;
		const BOOL isLastBpmChange = i==[song.bpmChangeArray count]-1;
		const int startRowNextChange = isLastBpmChange ? -1 : [(TMChangeSegment*)[song.bpmChangeArray objectAtIndex:i+1] noteRow];
		const float startBeatNextChange = isLastBpmChange ? MAXFLOAT : [TMNote noteRowToBeat:startRowNextChange];
		const float bps = [(TMChangeSegment*)[song.bpmChangeArray objectAtIndex:i] changeValue] / 60.0f;
	
		unsigned j;
		for( j=0; j<[song.freezeArray count]; j++) { // Foreach freeze
			TMChangeSegment* freeze = [song.freezeArray objectAtIndex:j];
			float freezeBeat = [TMNote noteRowToBeat:[freeze noteRow]];
			
			if(!isFirstBpmChange && startBeatThisChange >= freezeBeat)
				continue;
			if(!isLastBpmChange && freezeBeat > startBeatNextChange )
				continue;
			
			const float beatsSinceStartOfChange = freezeBeat - startBeatThisChange;
			const float freezeStartSecond = beatsSinceStartOfChange / bps;
			
			if( freezeStartSecond >= elapsedTime )
				break;
			
			// Apply the freeze
			elapsedTime -= [freeze changeValue]/1000.0f;
			
			if( freezeStartSecond >= elapsedTime ){
				// Lies within the stop
				*beatOut = freezeBeat;
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

+ (int) getNextBpmChangeFromBeat:(float) beat inSong:(TMSong*) song {
	int noteRow = [TMNote beatToNoteRow:beat];
	
	int i;	
	for(i=0; i<[song.bpmChangeArray count]; i++){
		if( [(TMChangeSegment*)[song.bpmChangeArray objectAtIndex:i] noteRow] > noteRow){
			return [(TMChangeSegment*)[song.bpmChangeArray objectAtIndex:i] noteRow];
		}
	}
	
	return -1;
}

+ (float) getPixelsPerNoteRowForBPS:(float) bps andSpeedMod:(float) sMod {
	
	double tFullScreenTime = kFullScreenSize/bps/60.0f;
		
	// Apply speedmod
	if(sMod != -1) {
		tFullScreenTime /= sMod;
	}				
		
	double tTimePerBeat = [TimingUtil getTimeInBeatForBPS:bps];	
	float tNoteRowsOnScr = (tFullScreenTime/tTimePerBeat)*kRowsPerBeat;
	float tPxDistBetweenRows = kFullScreenSize/tNoteRowsOnScr;				
	
	return tPxDistBetweenRows;
}

@end
