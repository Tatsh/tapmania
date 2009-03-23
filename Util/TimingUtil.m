//
//  TimingUtil.m
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TimingUtil.h"
#import "TMSong.h"
#import "TMChangeSegment.h"
#import "Judgement.h"

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

+ (float) getBpsAtBeat:(float) beat inSong:(TMSong*) song{
	int noteRow = [TMNote beatToNoteRow:beat];
	
	int i;	
	for(i=0; i<song.m_nBpmChangeCount-1; i++){
		if( [(TMChangeSegment*)song.m_aBpmChangeArray[i+1] m_fNoteRow] > noteRow){
			break;
		}
	}
	
	return [(TMChangeSegment*)song.m_aBpmChangeArray[i] m_fChangeValue];
}

+ (float) getElapsedTimeFromBeat:(float) beat inSong:(TMSong*) song {
	float elapsedTime = 0.0f;
	elapsedTime += song.m_dGap;
	
	int noteRow = [TMNote beatToNoteRow:beat];
	unsigned i;
	
	for(i=0; i<song.m_nFreezeCount; i++){
		if([(TMChangeSegment*)song.m_aFreezeArray[i] m_fNoteRow] >= noteRow) {
			break;
		}
		
		elapsedTime += [(TMChangeSegment*)song.m_aFreezeArray[i] m_fChangeValue]/1000.0f;		
	}
	
	for(i=0; i<song.m_nBpmChangeCount; i++){
		const BOOL isLastBpmChange = i == song.m_nBpmChangeCount-1;
		const float bps = [(TMChangeSegment*)song.m_aBpmChangeArray[i] m_fChangeValue]; 
		
		if(isLastBpmChange){
			elapsedTime += [TMNote noteRowToBeat:noteRow]/bps;
		} else {
			const int startRowThisChange = [(TMChangeSegment*)song.m_aBpmChangeArray[i] m_fNoteRow]; 
			const int startRowNextChange = [(TMChangeSegment*)song.m_aBpmChangeArray[i+1] m_fNoteRow];
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

	elapsedTime -= song.m_dGap;
	
	unsigned i;
	for( i=0; i<song.m_nBpmChangeCount; i++) { // Foreach bpm change in the song
		
		const int startRowThisChange = [(TMChangeSegment*)song.m_aBpmChangeArray[i] m_fNoteRow]; 
		const float startBeatThisChange = [TMNote noteRowToBeat:startRowThisChange]; 
		const BOOL isFirstBpmChange = i==0;
		const BOOL isLastBpmChange = i==song.m_nBpmChangeCount-1;
		const int startRowNextChange = isLastBpmChange ? -1 : [(TMChangeSegment*)song.m_aBpmChangeArray[i+1] m_fNoteRow];
		const float startBeatNextChange = isLastBpmChange ? MAXFLOAT : [TMNote noteRowToBeat:startRowNextChange];
		const float bps = [(TMChangeSegment*)song.m_aBpmChangeArray[i] m_fChangeValue];
	
		unsigned j;
		for( j=0; j<song.m_nFreezeCount; j++) { // Foreach freeze
			TMChangeSegment* freeze = song.m_aFreezeArray[j];
			float freezeBeat = [TMNote noteRowToBeat:[freeze m_fNoteRow]];
			
			if(!isFirstBpmChange && startBeatThisChange >= freezeBeat)
				continue;
			if(!isLastBpmChange && freezeBeat > startBeatNextChange )
				continue;
			
			const float beatsSinceStartOfChange = freezeBeat - startBeatThisChange;
			const float freezeStartSecond = beatsSinceStartOfChange / bps;
			
			if( freezeStartSecond >= elapsedTime )
				break;
			
			// Apply the freeze
			elapsedTime -= [freeze m_fChangeValue]/1000.0f;
			
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
	for(i=0; i<song.m_nBpmChangeCount; i++){
		if( [(TMChangeSegment*)song.m_aBpmChangeArray[i] m_fNoteRow] > noteRow){
			return [(TMChangeSegment*)song.m_aBpmChangeArray[i] m_fNoteRow];
		}
	}
	
	return -1;
}

+ (float) getPixelsPerNoteRowForBPS:(float) bps andSpeedMod:(float) sMod {
	
	double tFullScreenTime = kFullScreenSize/bps/60.0f;
		
	// Apply speedmod
	if(sMod != 1) {
		tFullScreenTime /= sMod;
	}				
		
	double tTimePerBeat = [TimingUtil getTimeInBeatForBPS:bps];	
	float tNoteRowsOnScr = (tFullScreenTime/tTimePerBeat)*kRowsPerBeat;
	float tPxDistBetweenRows = kFullScreenSize/tNoteRowsOnScr;				
	
	return tPxDistBetweenRows;
}

+ (TMJudgement) getJudgementByScore:(TMNoteScore)noteScore {
	if(noteScore == kNoteScore_W1E || noteScore == kNoteScore_W1L) {
		return kJudgementW1;
	} else if(noteScore == kNoteScore_W2E || noteScore == kNoteScore_W2L) {
		return kJudgementW2;
	} else if(noteScore == kNoteScore_W3E || noteScore == kNoteScore_W3L) {
		return kJudgementW3;
	} else if(noteScore == kNoteScore_W4E || noteScore == kNoteScore_W4L) {
		return kJudgementW4;
	} else if(noteScore == kNoteScore_W5E || noteScore == kNoteScore_W5L) {						
		return kJudgementW5;
	} else {
		return kJudgementMiss;
	}	
}

+ (TMNoteScore) getNoteScoreByDelta:(float)delta andTimingFlag:(TMTimingFlag) flag {
	if(delta <= 0.022500) {
		if(flag == kTimingFlagEarly)
			return kNoteScore_W1E;
		return kNoteScore_W1L;
		
	} else if(delta <= 0.045000) {
		if(flag == kTimingFlagEarly)
			return kNoteScore_W2E;
		return kNoteScore_W2L;
		
	} else if(delta <= 0.090000) {
		if(flag == kTimingFlagEarly)
			return kNoteScore_W3E;
		return kNoteScore_W3L;
		
	} else if(delta <= 0.135000) {
		if(flag == kTimingFlagEarly)
			return kNoteScore_W4E;
		return kNoteScore_W4L;
		
	} else if(delta <= 0.180000) {						
		if(flag == kTimingFlagEarly)
			return kNoteScore_W5E;
		return kNoteScore_W5L;
		
	} else {
		if(flag == kTimingFlagEarly)
			return kNoteScore_MissE;
		return kNoteScore_MissL;
		
	}		
}

+ (float) getLifebarChangeByNoteScore:(TMNoteScore)noteScore {
	if(noteScore == kNoteScore_W1E || noteScore == kNoteScore_W1L) {
		return 0.1f;
	} else if(noteScore == kNoteScore_W2E || noteScore == kNoteScore_W2L) {
		return 0.05f;
	} else if(noteScore == kNoteScore_W3E || noteScore == kNoteScore_W3L) {
		return 0.02f;
	} else if(noteScore == kNoteScore_W4E || noteScore == kNoteScore_W4L) {
		return 0.01f;
	} else if(noteScore == kNoteScore_W5E || noteScore == kNoteScore_W5L) {						
		return 0.0f;
	} else {
		// Miss
		return -0.1f;
	}
}

@end
