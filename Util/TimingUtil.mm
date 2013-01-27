//
//  $Id$
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

#import "GameState.h"
#import "DisplayUtil.h"

extern TMGameState *g_pGameState;

@implementation TimingUtil

+ (double)getCurrentTime
{
    static mach_timebase_info_data_t sTimebaseInfo;
    uint64_t time = mach_absolute_time();
    uint64_t nanos;

    if ( sTimebaseInfo.denom == 0 )
    {
        (void) mach_timebase_info(&sTimebaseInfo);
    }

    nanos = time * sTimebaseInfo.numer / sTimebaseInfo.denom;
    return ((double) nanos / 1000000000.0);
}

+ (double)getTimeInBeatForBPS:(float)bps
{
    /*
        For example max300 would be:
        300 bpm = 5 beats per second which makes 0.2 sec. (200 ms.) == one beat.
     */

    return 1.0 / bps;
}

+ (float)getBpsAtBeat:(float)beat inSong:(TMSong *)song
{
    int noteRow = [TMNote beatToNoteRow:beat];

    int cnt = [song getBpmChangeCount] - 1;
    int pos = 0;
    for ( ; pos < cnt; ++pos )
    {
        TMChangeSegment *seg = [song getBpmChangeAt:pos + 1];
        if ( seg && seg.m_fNoteRow > noteRow )
        {
            break;
        }
    }

    TMChangeSegment *seg = [song getBpmChangeAt:pos];
    return seg.m_fChangeValue;
}

+ (float)getElapsedTimeFromBeat:(float)beat inSong:(TMSong *)song
{
    float elapsedTime = 0.0f;
    elapsedTime += song.m_dGap;

    int noteRow = [TMNote beatToNoteRow:beat];

    int freezeCnt = [song getFreezeCount];
    int i;
    for ( i = 0; i < freezeCnt; ++i )
    {
        TMChangeSegment *seg = [song getFreezeAt:i];
        if ( seg && seg.m_fNoteRow >= noteRow )
        {
            break;
        }

        elapsedTime += seg.m_fChangeValue / 1000.0f;
    }

    int bpmCnt = [song getBpmChangeCount];
    for ( i = 0; i < bpmCnt; ++i )
    {
        const BOOL isLastBpmChange = i == bpmCnt - 1;
        TMChangeSegment *seg = [song getBpmChangeAt:i];
        const float bps = seg.m_fChangeValue;

        if ( isLastBpmChange )
        {
            elapsedTime += [TMNote noteRowToBeat:noteRow] / bps;
        }
        else
        {
            TMChangeSegment *segT = seg;
            TMChangeSegment *segN = [song getBpmChangeAt:i + 1];

            const int startRowThisChange = [segT m_fNoteRow];
            const int startRowNextChange = [segN m_fNoteRow];
            const int rowsInSegment = fminl(startRowNextChange - startRowThisChange, noteRow);
            elapsedTime += [TMNote noteRowToBeat:rowsInSegment] / bps;
            noteRow -= rowsInSegment;
        }

        if ( noteRow <= 0 )
        {
            return elapsedTime - g_pGameState->m_dGlobalOffset;
        }
    }

    return elapsedTime - g_pGameState->m_dGlobalOffset;
}

+ (void)getBeatAndBPSFromElapsedTime:(double)elapsedTime beatOut:(float *)beatOut bpsOut:(float *)bpsOut freezeOut:(BOOL *)freezeOut inSong:(TMSong *)song
{

    elapsedTime -= song.m_dGap;
    elapsedTime += g_pGameState->m_dGlobalOffset;

    unsigned i;
    for ( i = 0; i < [song getBpmChangeCount]; i++ )
    { // Foreach bpm change in the song

        TMChangeSegment *segT = [song getBpmChangeAt:i];
        TMChangeSegment *segN = [song getBpmChangeAt:i + 1];

        const int startRowThisChange = segT.m_fNoteRow;
        const float startBeatThisChange = [TMNote noteRowToBeat:startRowThisChange];
        const BOOL isFirstBpmChange = i == 0;
        const BOOL isLastBpmChange = i == [song getBpmChangeCount] - 1;
        const int startRowNextChange = isLastBpmChange ? -1 : segN.m_fNoteRow;
        const float startBeatNextChange = isLastBpmChange ? MAXFLOAT : [TMNote noteRowToBeat:startRowNextChange];
        const float bps = segT.m_fChangeValue;

        unsigned j;
        for ( j = 0; j < [song getFreezeCount]; j++ )
        { // Foreach freeze
            TMChangeSegment *freeze = [song getFreezeAt:j];
            float freezeBeat = [TMNote noteRowToBeat:[freeze m_fNoteRow]];

            if ( !isFirstBpmChange && startBeatThisChange >= freezeBeat )
            {
                continue;
            }
            if ( !isLastBpmChange && freezeBeat > startBeatNextChange )
            {
                continue;
            }

            const float beatsSinceStartOfChange = freezeBeat - startBeatThisChange;
            const float freezeStartSecond = beatsSinceStartOfChange / bps;

            if ( freezeStartSecond >= elapsedTime )
            {
                break;
            }

            // Apply the freeze
            elapsedTime -= [freeze m_fChangeValue] / 1000.0f;

            if ( freezeStartSecond >= elapsedTime )
            {
                // Lies within the stop
                *beatOut = freezeBeat;
                *bpsOut = bps;
                *freezeOut = YES;    // In freeze
                return;
            }
        }

        const float beatsInThisChangeSegment = startBeatNextChange - startBeatThisChange;
        const float secondsInThisChangeSegment = beatsInThisChangeSegment / bps;

        if ( isLastBpmChange || elapsedTime <= secondsInThisChangeSegment )
        {
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

+ (int)getNextBpmChangeFromBeat:(float)beat inSong:(TMSong *)song
{
    int noteRow = [TMNote beatToNoteRow:beat];

    int i, cnt = [song getBpmChangeCount];
    for ( i = 0; i < cnt; ++i )
    {
        TMChangeSegment *seg = [song getBpmChangeAt:i];
        if ( seg && seg.m_fNoteRow > noteRow )
        {
            return seg.m_fNoteRow;
        }
    }

    return -1;
}

+ (float)getPixelsPerNoteRowForBPS:(float)bps andSpeedMod:(float)sMod
{
    static double screenHeight = [DisplayUtil getDeviceDisplaySize].height;
    double tFullScreenTime = screenHeight / bps / (screenHeight / kRowsOnScreen);

    // Apply speedmod
    if ( sMod > 0.0f )
    {
        tFullScreenTime /= sMod;
    }

    double tTimePerBeat = [TimingUtil getTimeInBeatForBPS:bps];
    float tNoteRowsOnScr = (tFullScreenTime / tTimePerBeat) * kRowsPerBeat;
    float tPxDistBetweenRows = screenHeight / tNoteRowsOnScr;

    return tPxDistBetweenRows;
}

+ (TMJudgement)getJudgementByDelta:(float)delta
{
    if ( delta <= 0.022500 )
    {
        return kJudgementW1;
    }
    else if ( delta <= 0.045000 )
    {
        return kJudgementW2;
    }
    else if ( delta <= 0.090000 )
    {
        return kJudgementW3;
    }
    else if ( delta <= 0.135000 )
    {
        return kJudgementW4;
    }
    else if ( delta <= 0.180000 )
    {
        return kJudgementW5;
    }
    else
    {
        return kJudgementMiss;
    }
}

+ (float)getLifebarChangeByNoteScore:(TMJudgement)noteScore
{
    if ( noteScore == kJudgementW1 )
    {
        return 0.008f;
    }
    else if ( noteScore == kJudgementW2 )
    {
        return 0.008f;
    }
    else if ( noteScore == kJudgementW3 )
    {
        return 0.004f;
    }
    else if ( noteScore == kJudgementW4 )
    {
        return 0.000f;
    }
    else if ( noteScore == kJudgementW5 )
    {
        return -0.040f;
    }
    else if ( noteScore == kJudgementMineHit )
    {
        return -0.160f;
    }
    else
    {
        // Miss
        return -0.080f;
    }
}

@end
