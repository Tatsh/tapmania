//
//  $Id$
//  TMSteps.m
//  TapMania
//
//  Created by Alex Kremer on 04.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <numeric>
#import <vector>

#import "TMSteps.h"
#import "TMNote.h"
#import "TapNote.h"
#import "TapMine.h"
#import "HoldNote.h"

#import "TimingUtil.h"
#import "TMMessage.h"
#import "ThemeManager.h"
#import "TapMania.h"
#import "JoyPad.h"

#import "GameState.h"

extern TMGameState *g_pGameState;

@implementation TMSteps
{
    std::vector<double> m_syncSamples;
}

- (id)init
{
    self = [super init];
    if (!self)
        return nil;

    int i;

    // Alloc space for tracks
    for (i = 0; i < kNumOfAvailableTracks; i++)
    {
        m_pTracks[i] = [[TMTrack alloc] init];

        // Cache metrics
        mt_TapNotes[i] = RECT_SKIN_METRIC(([NSString stringWithFormat:@"TapNote %d", i]));
        mt_TapNoteRotations[i] = FLOAT_SKIN_METRIC(([NSString stringWithFormat:@"TapNote Rotation %d", i]));
        mt_HalfOfArrowHeight[i] = mt_TapNotes[i].size.height / 2;

        mt_Receptors[i] = RECT_SKIN_METRIC(([NSString stringWithFormat:@"ReceptorRow %d", i]));

        m_dLastHitTimes[i] = 0.0f;
    }

    mt_HoldCap = SIZE_SKIN_METRIC(@"HoldNote Cap");
    mt_HoldBody = SIZE_SKIN_METRIC(@"HoldNote Body");

    mt_NotesStartPos = POINT_METRIC(@"SongPlay NotesStartPosition");
    mt_NotesOutOfScopePos = POINT_METRIC(@"SongPlay NotesOutOfScopePosition");

    // Cache textures
    t_TapNote = (TapNote *) SKIN_TEXTURE(@"DownTapNote");
    t_TapMine = (TapMine *) SKIN_TEXTURE(@"TapMine");
    t_HoldNoteActive = (HoldNote *) SKIN_TEXTURE(@"HoldBody DownActive");
    t_HoldNoteInactive = (HoldNote *) SKIN_TEXTURE(@"HoldBody DownInactive");

    t_HoldBottomCapActive = SKIN_TEXTURE(@"HoldBody BottomCapActive");
    t_HoldBottomCapInactive = SKIN_TEXTURE(@"HoldBody BottomCapInactive");

    // Drop track positions to first elements
    for (int i = 0; i < kNumOfAvailableTracks; i++)
    {
        m_nTrackPos[i] = 0;
    }

    return self;
}

- (void)dealloc
{
    TMLog(@"Release steps!");

    for (int i = 0; i < kNumOfAvailableTracks; ++i)
    {
        [m_pTracks[i] release];
    }

    [super dealloc];
}

- (int)getDifficultyLevel
{
    return m_nDifficultyLevel;
}

- (void)setDifficultyLevel:(int)level
{
    m_nDifficultyLevel = level;
}

- (TMSongDifficulty)getDifficulty
{
    return m_nDifficulty;
}

- (void)setNote:(TMNote *)note toTrack:(int)trackIndex onNoteRow:(int)noteRow
{
    [m_pTracks[trackIndex] setNote:note onNoteRow:noteRow];
}

- (TMNote *)getNote:(int)index fromTrack:(int)trackIndex
{
    return [m_pTracks[trackIndex] getNote:index];
}

- (TMNote *)getNoteFromRow:(int)noteRow forTrack:(int)trackIndex
{
    return [m_pTracks[trackIndex] getNoteFromRow:noteRow];
}

- (BOOL)hasNoteAtRow:(int)noteRow forTrack:(int)trackIndex
{
    return [m_pTracks[trackIndex] hasNoteAtRow:noteRow];
}

- (int)getNotesCountForTrack:(int)trackIndex
{
    return [m_pTracks[trackIndex] getNotesCount];
}

- (int)getTotalNotes
{
    int total = 0;

    for (int i = 0; i < kNumOfAvailableTracks; ++i)
    {
        total += [m_pTracks[i] getNotesCount];
    }

    return total;
}

- (int)getTotalHolds
{
    int total = 0;

    for (int i = 0; i < kNumOfAvailableTracks; ++i)
    {
        total += [m_pTracks[i] getHoldsCount];
    }

    return total;
}

- (int)getTapAndHoldNotesCountForTrack:(int)trackIndex
{
    return [m_pTracks[trackIndex] getTapAndHoldNotesCount];
}

- (int)getTotalTapAndHoldNotes
{
    int total = 0;

    for (int i = 0; i < kNumOfAvailableTracks; ++i)
    {
        total += [m_pTracks[i] getTapAndHoldNotesCount];
    }

    return total;
}

- (BOOL)checkAllNotesHitFromRow:(int)noteRow withNoteTime:(double)inNoteTime
{
    // Check whether other tracks has any notes which are not hit yet and are on the same noterow
    BOOL allNotesHit = YES;
    int tr = 0;
    TMNote *notesInRow[kNumOfAvailableTracks];

    for (; tr < kNumOfAvailableTracks; ++tr)
    {
        notesInRow[tr] = nil;
        TMNote *n = [self getNoteFromRow:noteRow forTrack:tr];

        // If found - check
        if (n != nil && n.m_nType != kNoteType_Empty && n.m_nType != kNoteType_Mine)
        {
            if (!n.m_bIsHit)
            {
                allNotesHit = NO;
            } else
            {
                notesInRow[tr] = n;
            }
        }
    }

    // Mark all hit if all notes actually were hit
    if (allNotesHit)
    {

        // Get the worse scoring of all hit notes
        double worseDelta = 0.0;
        double noteTiming = 0.0;
        TMTimingFlag timingFlag;

        for (tr = 0; tr < kNumOfAvailableTracks; ++tr)
        {
            if (notesInRow[tr] != nil)
            {
                double timing = inNoteTime - notesInRow[tr].m_dHitTime;
                noteTiming = timing; // this is only used in sync song where are no double taps

                double thisDelta = fabs(timing);

                if (thisDelta > worseDelta)
                {
                    worseDelta = thisDelta;
                    timingFlag = timing < 0 ? kTimingFlagEarly : kTimingFlagLate;
                }
            }
        }

        TMJudgement noteScore = [TimingUtil getJudgementByDelta:worseDelta];

        if (g_pGameState->m_bIsGlobalSync)
        {
            if (m_syncSamples.size() >= kSyncSamples)
            {
                g_pGameState->m_dGlobalOffset +=
                        std::accumulate(m_syncSamples.begin(), m_syncSamples.end(),
                                0.0) / (double)m_syncSamples.size();
                TMLog(@"Global offset becomes: %f", g_pGameState->m_dGlobalOffset);

                m_syncSamples.clear();
            }

            m_syncSamples.push_back(noteTiming/16.0); // use smaller steps in samples
            TMLog(@"timing of note in Global sync: %f", noteTiming);
        }

        // And now actually mark them hit
        for (tr = 0; tr < kNumOfAvailableTracks; ++tr)
        {
            if (notesInRow[tr] != nil)
            {
                [(notesInRow[tr]) score:noteScore withTimingFlag:timingFlag];
            }
        }
    }

    return allNotesHit;
}

- (void)markAllNotesLostFromRow:(int)noteRow
{
    int tr = 0;
    for (; tr < kNumOfAvailableTracks; ++tr)
    {

        TMNote *n = [self getNoteFromRow:noteRow forTrack:tr];

        // If found - check
        if (n != nil && n.m_nType != kNoteType_Mine)
        {
            [n markLost];
            [n score:kJudgementMiss withTimingFlag:kTimingFlagLate];

            // Extra judgement for hold notes..
            if (n.m_nType == kNoteType_HoldHead)
            {
                [n markHoldLost];
            }
        }
    }
}


- (int)getFirstNoteRow
{
    int i;
    int minNoteRow = INT_MAX;

    for (i = 0; i < kNumOfAvailableTracks; i++)
    {
        int j;

        int total = [m_pTracks[i] getNotesCount];
        for (j = 0; [m_pTracks[i] getNote:j].m_nType == kNoteType_Empty && j < total; j++);

        // Get the smallest
        minNoteRow = (int) fminf((float) minNoteRow, (float) [(TMNote *) [m_pTracks[i] getNote:j] m_nStartNoteRow]);
    }

    return minNoteRow;
}

- (int)getLastNoteRow
{
    int i;
    int maxNoteRow = 0;

    for (i = 0; i < kNumOfAvailableTracks; i++)
    {
        // Get the biggest
        TMNote *lastNote = [m_pTracks[i] getNote:[m_pTracks[i] getNotesCount] - 1];
        maxNoteRow = (int) fmaxf((float) maxNoteRow, (float) lastNote.m_nType == kNoteType_HoldHead ? [lastNote m_nStopNoteRow] : [lastNote m_nStartNoteRow]);
    }

    return maxNoteRow;
}

- (void)dump
{
    printf("Dumping steps: %d/%d\n\n", m_nDifficulty, m_nDifficultyLevel);
    for (int i = 0; i < kNumOfAvailableTracks; i++)
    {

        printf("row %d |", i);
        BOOL holdActive = NO;

        for (int j = 0; j < [m_pTracks[i] getNotesCount]; j++)
        {
            TMNote *pNote = [m_pTracks[i] getNote:j];
            char c = ' ';

            switch (pNote.m_nType)
            {
                case kNoteType_HoldHead:
                    c = '#';
                    holdActive = YES;
                    break;
                case kNoteType_Original:
                    c = '*';
                    holdActive = NO;
                    break;
                case kNoteType_Mine:
                    c = 'm';
                    break;
                case kNoteType_Empty:
                    c = '0';
                    break;
                default:
                    if (holdActive)
                        c = '=';
            }

            printf("%c", c);
        }
        printf("|\n");
    }
}

/* TMLogicUpdater stuff */
- (void)update:(float)fDelta
{
    if (!g_pGameState->m_bPlayingGame)
        return;

    float currentBeat, currentBps;
    BOOL hasFreeze;

    [TimingUtil getBeatAndBPSFromElapsedTime:g_pGameState->m_dElapsedTime beatOut:&currentBeat bpsOut:&currentBps freezeOut:&hasFreeze inSong:g_pGameState->m_pSong];

    // Calculate animation of the tap notes. The speed of the animation is actually one frame per beat
    float timeInBeat = [TimingUtil getTimeInBeatForBPS:currentBps];
    [t_TapNote setM_fFrameTime:timeInBeat];
    [t_TapMine setM_fFrameTime:timeInBeat / 2.0f];

    [t_TapNote update:fDelta];
    [t_TapMine update:fDelta];

    // If freeze - stop animating the notes but still check for hits etc.
    if (hasFreeze)
    {
        [t_TapNote pauseAnimation];
        [t_TapMine pauseAnimation];
    } else
    {
        [t_TapNote continueAnimation];
        [t_TapMine continueAnimation];
    }

    int i;

    // For every track
    for (i = 0; i < kNumOfAvailableTracks; i++)
    {
        // Search in this track for items starting at index:
        int startIndex = m_nTrackPos[i];
        int j;

        // This will hold the Y coordinate of the previous note in this track
        float lastNoteYPosition = mt_Receptors[i].origin.y;

        TMNote *prevNote = nil;

        double lastHitTime = [[TapMania sharedInstance].joyPad getTouchTimeForButton:(JPButton) i] - g_pGameState->m_dPlayBackStartTime;
        BOOL testHit = NO;

        // For all interesting notes in the track
        for (j = startIndex; j < [self getNotesCountForTrack:i]; ++j)
        {
            TMNote *note = [self getNote:j fromTrack:i];

            // We are not handling empty notes though
            if (note.m_nType == kNoteType_Empty)
                continue;

            // Get beats out of noteRows
            float beat = [TMNote noteRowToBeat:note.m_nStartNoteRow];
            float tillBeat = note.m_nStopNoteRow == -1 ? -1.0f : [TMNote noteRowToBeat:note.m_nStopNoteRow];

            float noteBps = [TimingUtil getBpsAtBeat:beat inSong:g_pGameState->m_pSong];

            float noteYPosition = lastNoteYPosition;
            float holdBottomCapYPosition = mt_NotesStartPos.y;

            int lastNoteRow = prevNote ? prevNote.m_nStartNoteRow : [TMNote beatToNoteRow:currentBeat];
            int nextBpmChangeNoteRow = [TimingUtil getNextBpmChangeFromBeat:[TMNote noteRowToBeat:lastNoteRow] inSong:g_pGameState->m_pSong];

            double noteTime = [TimingUtil getElapsedTimeFromBeat:beat inSong:g_pGameState->m_pSong];
            note.m_dTimeTillHit = noteTime - g_pGameState->m_dElapsedTime;

            // A mine will explode if we are touching the corresponding pad button at the time it passes
            if (!g_pGameState->m_bAutoPlay && note.m_nType == kNoteType_Mine && !note.m_bIsMineHit)
            {
                if (fabsf(noteTime - g_pGameState->m_dElapsedTime) <= kMineHitSearchEpsilon)
                {
                    // Ok. this mine seems to be close enough to the receptors
                    double lastReleaseTime = [[TapMania sharedInstance].joyPad getReleaseTimeForButton:(JPButton) i] - g_pGameState->m_dPlayBackStartTime;

                    if (lastHitTime > lastReleaseTime)
                    {
                        // seems like we are holding now so should explode here
                        TMLog(@"BOOM!");
                        [note mineHit];
                        [note score:kJudgementMineHit withTimingFlag:kTimingFlagInvalid];
                    }
                }
            }

            if (g_pGameState->m_bAutoPlay)
            {
                if (fabsf(noteTime - g_pGameState->m_dElapsedTime) <= 0.02f)
                {
                    if (note.m_nType != kNoteType_Mine && !note.m_bIsHit)
                    {
                        lastHitTime = g_pGameState->m_dElapsedTime;
                        testHit = (m_dLastHitTimes[i] == lastHitTime) ? NO : YES;
                    }
                }
            }
            else
            {
                if (note.m_nType != kNoteType_Mine && !note.m_bIsHit && fabsf(noteTime - lastHitTime) <= kHitSearchEpsilon)
                {
                    testHit = (m_dLastHitTimes[i] == lastHitTime) ? NO : YES;
                }
            }

            // Now for every bpmchange we must apply all bpmchange related offsets
            while (nextBpmChangeNoteRow != -1 && nextBpmChangeNoteRow < note.m_nStartNoteRow)
            {
                float tBps = [TimingUtil getBpsAtBeat:[TMNote noteRowToBeat:nextBpmChangeNoteRow - 1] inSong:g_pGameState->m_pSong];

                noteYPosition -= (nextBpmChangeNoteRow - lastNoteRow) * [TimingUtil getPixelsPerNoteRowForBPS:tBps andSpeedMod:g_pGameState->m_dSpeedModValue];
                lastNoteRow = nextBpmChangeNoteRow;
                nextBpmChangeNoteRow = [TimingUtil getNextBpmChangeFromBeat:[TMNote noteRowToBeat:nextBpmChangeNoteRow] inSong:g_pGameState->m_pSong];
            }

            // Calculate for last segment
            noteYPosition -= (note.m_nStartNoteRow - lastNoteRow) * [TimingUtil getPixelsPerNoteRowForBPS:noteBps andSpeedMod:g_pGameState->m_dSpeedModValue];
            note.m_fStartYPosition = noteYPosition;

            /* We must also calculate the Y position of the bottom cap of the hold if we handle a hold note */
            if (note.m_nType == kNoteType_HoldHead)
            {
                // If we hit (was ever holding) the note now we must fix it on the receptor base
                if (note.m_bIsHit)
                {
                    note.m_fStartYPosition = mt_Receptors[i].origin.y;
                }

                // Start from the calculated note head position
                holdBottomCapYPosition = noteYPosition;
                lastNoteRow = note.m_nStartNoteRow;

                nextBpmChangeNoteRow = [TimingUtil getNextBpmChangeFromBeat:[TMNote noteRowToBeat:lastNoteRow] inSong:g_pGameState->m_pSong];

                // Now for every bpmchange we must apply all bpmchange related offsets
                while (nextBpmChangeNoteRow != -1 && nextBpmChangeNoteRow < note.m_nStopNoteRow)
                {
                    float tBps = [TimingUtil getBpsAtBeat:[TMNote noteRowToBeat:nextBpmChangeNoteRow - 1] inSong:g_pGameState->m_pSong];

                    holdBottomCapYPosition -= (nextBpmChangeNoteRow - lastNoteRow) * [TimingUtil getPixelsPerNoteRowForBPS:tBps andSpeedMod:g_pGameState->m_dSpeedModValue];
                    lastNoteRow = nextBpmChangeNoteRow;
                    nextBpmChangeNoteRow = [TimingUtil getNextBpmChangeFromBeat:[TMNote noteRowToBeat:nextBpmChangeNoteRow] inSong:g_pGameState->m_pSong];
                }

                // Calculate for last segment of the hold body
                float capBps = [TimingUtil getBpsAtBeat:tillBeat inSong:g_pGameState->m_pSong];
                holdBottomCapYPosition -= (note.m_nStopNoteRow - lastNoteRow) * [TimingUtil getPixelsPerNoteRowForBPS:capBps andSpeedMod:g_pGameState->m_dSpeedModValue];

                note.m_fStopYPosition = holdBottomCapYPosition;
            }

            // Check whether we already missed a note (hold head too)
            double passedTime = g_pGameState->m_dElapsedTime - noteTime;
            if (note.m_nType != kNoteType_Mine && !note.m_bIsLost && !note.m_bIsHit && passedTime >= kHitSearchEpsilon)
            {
                [self markAllNotesLostFromRow:note.m_nStartNoteRow];
            }

            // Check whether this note is already out of scope
            if (note.m_nType != kNoteType_HoldHead && noteYPosition >= mt_NotesOutOfScopePos.y && passedTime >= kHitSearchEpsilon)
            {

                ++m_nTrackPos[i];
                continue; // Skip this note
            }

            // Now the same for hold notes
            if (note.m_nType == kNoteType_HoldHead)
            {
                if (note.m_bIsHit && holdBottomCapYPosition >= mt_Receptors[i].origin.y)
                {
                    if (note.m_bIsHeld)
                    {
                        [note markHoldHeld];
                    }

                    ++m_nTrackPos[i];
                    continue; // Skip this hold already
                } else if (!note.m_bIsHit && holdBottomCapYPosition >= mt_NotesOutOfScopePos.y)
                {
                    // Let the hold go till the end of the screen. The lifebar and the NG graphic is done already when the hold was lost
                    ++m_nTrackPos[i];
                    continue; // Skip
                }
            }

            // If the Y position is at the floor - jump to next track
            if (note.m_fStartYPosition <= -mt_TapNotes[i].size.height)
            {
                break; // Start another track coz this note is out of screen
            }

            // If we are at a hold arrow we must check it anyway
            if (note.m_nType == kNoteType_HoldHead)
            {
                double lastReleaseTime;

                if (g_pGameState->m_bAutoPlay)
                {
                    lastReleaseTime = lastHitTime - 0.01f;
                } else
                {
                    lastReleaseTime = [[TapMania sharedInstance].joyPad getReleaseTimeForButton:(JPButton) i] - g_pGameState->m_dPlayBackStartTime;
                }

                if (note.m_bIsHit && !note.m_bIsHoldLost && !note.m_bIsHolding)
                {
                    // This means we released the hold but we still can catch it again
                    if (fabsf(g_pGameState->m_dElapsedTime - note.m_dLastHoldReleaseTime) >= kHoldLostEpsilon)
                    {
                        [note markHoldLost];
                    }

                    // But maybe we have touched it again before it was marked as lost totally?
                    if (!note.m_bIsHoldLost && note.m_dLastHoldReleaseTime < lastHitTime)
                    {
                        [note startHolding:lastHitTime];
                    }
                } else if (note.m_bIsHit && !note.m_bIsHoldLost && note.m_bIsHolding)
                {
                    if (lastReleaseTime >= lastHitTime)
                    {
                        [note stopHolding:lastReleaseTime];
                    }
                }
            }

            // Check hit
            if (testHit && !note.m_bIsHit && !note.m_bIsLost)
            {
                // Mark this one as hit
                [note hit:lastHitTime];

                // Save this hit time for later checking
                m_dLastHitTimes[i] = lastHitTime;

                // Only ones for a run
                testHit = NO;

                // Check whether other tracks has any notes which are not hit yet and are on the same noterow
                // The routine below will automatically broadcast all required messages to make things work (score notes)
                [self checkAllNotesHitFromRow:note.m_nStartNoteRow withNoteTime:noteTime];

                // Also, should start holding if this is a hold note
                if (note.m_nType == kNoteType_HoldHead)
                {
                    [note startHolding:lastHitTime];
                }
            }

            prevNote = note;
            lastNoteYPosition = noteYPosition;
        }
    }
}

/* TMRenderable stuff */
- (void)render:(float)fDelta
{

    if (!g_pGameState->m_bPlayingGame)
        return;

    // For every track
    for (int i = 0; i < kNumOfAvailableTracks; ++i)
    {

        // Search in this track for items starting at index:
        int startIndex = m_nTrackPos[i];
        int j;

        // For all interesting notes in the track
        for (j = startIndex; j < [self getNotesCountForTrack:i]; j++)
        {
            TMNote *note = [self getNote:j fromTrack:i];

            // We are not handling empty notes though
            if (note.m_nType == kNoteType_Empty)
                continue;

            // We will draw the note only if it wasn't hit yet
            if (note.m_nType == kNoteType_HoldHead || !note.m_bMultiHit || note.m_bIsLost)
            {
                if (note.m_fStartYPosition <= -mt_TapNotes[i].size.height)
                {
                    break; // Start another track coz this note is out of screen
                }

                // Stealth mode - the best!!!11one
                if (!g_pGameState->m_bModStealth)
                {

                    // Hidden mod
                    if (g_pGameState->m_bModHidden && note.m_dTimeTillHit <= 1.2f)
                    {
                        float alpha = note.m_dTimeTillHit - 0.2f;
                        alpha = alpha < 0.0f ? 0.0f : alpha;
                        glColor4f(alpha, alpha, alpha, alpha);
                    }

                    // Sudden mod
                    if (g_pGameState->m_bModSudden)
                    {
                        float alpha = 0.0f;

                        if (note.m_dTimeTillHit <= 0.6f)
                        {
                            alpha = 1.0f - (note.m_dTimeTillHit + 0.2f);
                            alpha = alpha > 1.0f ? 1.0f : alpha;
                        }

                        glColor4f(alpha, alpha, alpha, alpha);
                    }

                    // If note is a holdnote
                    if (note.m_nType == kNoteType_HoldHead)
                    {
                        // Calculate body length
                        float bodyTopY = note.m_fStartYPosition + mt_HalfOfArrowHeight[i]; // Plus half of the tap note so that it will be overlapping
                        float bodyBottomY = note.m_fStopYPosition + mt_HalfOfArrowHeight[i]; // Make space for bottom cap

                        // Determine the track X position now
                        float holdX = mt_TapNotes[i].origin.x;

                        // Calculate the height of the hold's body
                        float totalBodyHeight = bodyTopY - bodyBottomY;
                        float offset = bodyBottomY;

                        // Draw every piece separately
                        do
                        {
                            float sizeOfPiece = totalBodyHeight > mt_HoldBody.height ? mt_HoldBody.height : totalBodyHeight;

                            // Don't draw if we are out of screen
                            if (offset + sizeOfPiece > mt_NotesStartPos.y)
                            {
                                if (note.m_bIsHolding)
                                {
                                    [t_HoldNoteActive drawBodyPieceWithSize:sizeOfPiece atPoint:CGPointMake(holdX, offset)];
                                } else
                                {
                                    [t_HoldNoteInactive drawBodyPieceWithSize:sizeOfPiece atPoint:CGPointMake(holdX, offset)];
                                }
                            }

                            totalBodyHeight -= mt_HoldBody.height;
                            offset += mt_HoldBody.height;
                        } while (totalBodyHeight > 0.0f);

                        // determine the position of the cap and draw it if needed
                        if (bodyBottomY > mt_NotesStartPos.y)
                        {
                            // Ok. must draw the cap
                            glEnable(GL_BLEND);

                            if (note.m_bIsHolding)
                            {
                                [t_HoldBottomCapActive drawInRect:CGRectMake(holdX, bodyBottomY - (mt_HoldCap.height - 1), mt_HoldCap.width, mt_HoldCap.height)];
                            } else
                            {
                                [t_HoldBottomCapInactive drawInRect:CGRectMake(holdX, bodyBottomY - (mt_HoldCap.height - 1), mt_HoldCap.width, mt_HoldCap.height)];
                            }

                            glDisable(GL_BLEND);
                        }
                    }

                    CGRect arrowRect = CGRectMake(mt_TapNotes[i].origin.x, note.m_fStartYPosition, mt_TapNotes[i].size.width, mt_TapNotes[i].size.height);
                    if (note.m_nType == kNoteType_HoldHead)
                    {
                        if (note.m_bIsHolding)
                        {
                            [t_TapNote drawHoldTapNoteHolding:note.m_nBeatType direction:(TMNoteDirection) i inRect:arrowRect];
                        } else
                        {
                            [t_TapNote drawHoldTapNoteReleased:note.m_nBeatType direction:(TMNoteDirection) i inRect:arrowRect];
                        }
                    } else if (note.m_nType == kNoteType_Mine)
                    {
                        [t_TapMine drawTapMineInRect:arrowRect];
                    } else
                    {
                        [t_TapNote drawTapNote:note.m_nBeatType direction:(TMNoteDirection) i inRect:arrowRect];
                    }

                    // Restore color/alpha settings
                    // TODO: restore. not just 1,1,1,1
                    glColor4f(1.0, 1.0, 1.0, 1.0);
                } // Stealth mod
            }
        }
    }
}

/* TMMessageSupport stuff */
- (void)handleMessage:(TMMessage *)message
{
}

@end
