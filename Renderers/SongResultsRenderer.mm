//
//  $Id$
//  SongResultsRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 21.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "SongResultsRenderer.h"

#import "TapMania.h"
#import "InputEngine.h"
#import "EAGLView.h"

#import "FontString.h"
#import "ThemeManager.h"

#import "TMSteps.h"
#import "SongPickerMenuRenderer.h"
#import "Label.h"
#import "DisplayUtil.h"
#import "GLUtil.h"

#import "GameState.h"

extern TMGameState *g_pGameState;

@interface SongResultsRenderer (Private)
- (TMGrade)gradeFromScore:(long)score fromMaxScore:(long)maxScore;
@end


@implementation SongResultsRenderer
{
    Texture2D *t_NoBanner;
}

- (void)dealloc
{

    // Here we MUST release memory used by the steps since after this place we will not need it anymore
    [g_pGameState->m_pSteps release];
    [g_pGameState->m_pSong release];
    [g_pGameState->m_sMods release];

    g_pGameState->m_pSong = nil;
    g_pGameState->m_pSteps = nil;

    for (int i = 0; i < kNumJudgementValues; ++i)
    {
        [m_pJudgeScores[i] release];
    }

    [m_pScore release];
    [m_pMaxCombo release];
    g_pGameState->m_nScore = g_pGameState->m_nCombo = 0;

    [super dealloc];
}

/* TMTransitionSupport methods */
- (void)setupForTransition
{
    [super setupForTransition];

    // Textures
    t_JudgeLabels = (TMFramedTexture *) TEXTURE(@"SongResults JudgeLabels");
    t_Grades = (TMFramedTexture *) TEXTURE(@"SongResults Grades");
    t_overlay = TEXTURE(@"SongResults Overlay");    
    t_NoBanner = TEXTURE(@"SongResults NoBanner");

    if (g_pGameState->m_pSong.m_sBackgroundFilePath != nil)
    {
        NSString *songPath = [[SongsDirectoryCache sharedInstance] getSongsPath:g_pGameState->m_pSong.m_iSongsPath];
        NSString *backgroundFilePath = [songPath stringByAppendingPathComponent:g_pGameState->m_pSong.m_sBackgroundFilePath];
        UIImage *img = [UIImage imageWithContentsOfFile:backgroundFilePath];
        if (img)
        {
            t_BG = [[Texture2D alloc] initWithImage:img columns:1 andRows:1];
        }
    }
    self.brightness = 0.5f;

    if (g_pGameState->m_pSong.bannerTexture != nil)
    {
        t_Banner = g_pGameState->m_pSong.bannerTexture;
    }
    else
    {
        t_Banner = t_NoBanner;
    }

    // Get metrics
    for (int i = 0; i < kNumJudgementValues; ++i)
    {
        NSString *k = [NSString stringWithFormat:@"SongResults JudgeLabelPositions %d", i];
        mt_JudgeLabels[i] = POINT_METRIC(k);
    }

    for (int i = 0; i < kNumJudgementValues; ++i)
    {
        NSString *k = [NSString stringWithFormat:@"SongResults JudgeScorePositions %d", i];
        mt_JudgeScores[i] = POINT_METRIC(k);
    }

    mt_MaxCombo = POINT_METRIC(@"SongResults MaxCombo");
    mt_MaxComboLabel = POINT_METRIC(@"SongResults MaxComboLabelPosition");

    mt_Score = POINT_METRIC(@"SongResults Score");
    mt_Grade = POINT_METRIC(@"SongResults Grade");
    mt_Banner = RECT_METRIC(@"SongResults Banner");

    int i, track;

    // asure we have zeros in all score counters
    for (i = 0; i < kNumJudgementValues; i++)
        m_nCounters[i] = 0;
    for (i = 0; i < kNumHoldScores; i++)
        m_nOkNgCounters[i] = 0;

    m_bReturnToSongSelection = NO;

    // Calculate
    for (track = 0; track < kNumOfAvailableTracks; track++)
    {
        int notesCount = [g_pGameState->m_pSteps getNotesCountForTrack:track];

        for (i = 0; i < notesCount; i++)
        {
            TMNote *note = [g_pGameState->m_pSteps getNote:i fromTrack:track];

            if (note.m_nType != kNoteType_Empty)
            {
                m_nCounters[note.m_nScore]++;

                if (note.m_nType == kNoteType_HoldHead)
                {
                    m_nOkNgCounters[note.m_nHoldScore]++;
                }
            }
        }
    }

    // Create font strings
    for (int i = 0; i < kNumJudgementValues; ++i)
    {
        if (i == 6)
        {
            m_pJudgeScores[i] = [[FontString alloc] initWithFont:@"MediumScore"
                                                         andText:[NSString stringWithFormat:@"%4d",
                                                                                            m_nOkNgCounters[kHoldScore_OK]]];
        } else
        {
            m_pJudgeScores[i] = [[FontString alloc] initWithFont:@"MediumScore"
                                                         andText:[NSString stringWithFormat:@"%4d", m_nCounters[i]]];
        }
    }

    m_pScore = [[FontString alloc] initWithFont:@"BigScore"
                                        andText:[NSString stringWithFormat:@"%8ld",
                                                                           g_pGameState->m_nScore]];
    [m_pScore setAlignment:UITextAlignmentCenter];

    m_pMaxCombo = [[FontString alloc] initWithFont:@"MediumScore"
                                           andText:[NSString stringWithFormat:@"%4d",
                                                                              g_pGameState->m_nCombo]];

    if (g_pGameState->m_bFailed || g_pGameState->m_bGaveUp)
    {
        m_Grade = kGradeE;

    } else if (m_nCounters[kJudgementW1] == [g_pGameState->m_pSteps getTotalTapAndHoldNotes])
    {

        m_Grade = kGradeAAAA;

    } else if (m_nCounters[kJudgementW3] == 0 && m_nCounters[kJudgementW4] == 0
            && m_nCounters[kJudgementW5] == 0 && m_nCounters[kJudgementMiss] == 0)
    {

        m_Grade = kGradeAAA;

    } else
    {

        m_Grade = [self gradeFromScore:g_pGameState->m_nScore
                          fromMaxScore://[g_pGameState->m_pSteps getDifficultyLevel]*
                                  10000000];
    }

    // Set difficulty and mods display
    [(Label *) [self findControl:@"SongResults DifficultyLabel"] setName:
            [TMSong difficultyToString:g_pGameState->m_nSelectedDifficulty]];

    [(Label *) [self findControl:@"SongResults ModsLabel"] setName:g_pGameState->m_sMods];


    // Save this score if it's better than it was
    NSNumber *diff = [NSNumber numberWithInt:g_pGameState->m_nSelectedDifficulty];
    NSString *sql = [NSString stringWithFormat:@"WHERE hash = '%@' AND difficulty = '%@'", g_pGameState->m_pSong.m_sHash, diff];
    TMSongSavedScore *savedScore = [TMSongSavedScore findFirstByCriteria:sql];

    if (savedScore != nil)
    {
        TMLog(@"Some old score found: %@", savedScore.bestScore);

        if ([savedScore.bestScore intValue] < g_pGameState->m_nScore)
        {
            TMLog(@"Better score. Update.");
            savedScore.bestScore = [NSNumber numberWithInt:g_pGameState->m_nScore];
            savedScore.bestGrade = [NSNumber numberWithInt:m_Grade];
            [savedScore save];
        }
    } else
    {
        TMLog(@"Save score first time!");
        savedScore = [[TMSongSavedScore alloc] init];
        savedScore.hash = g_pGameState->m_pSong.m_sHash;
        savedScore.difficulty = diff;
        savedScore.bestScore = [NSNumber numberWithInt:g_pGameState->m_nScore];
        savedScore.bestGrade = [NSNumber numberWithInt:m_Grade];
        [savedScore save];
    }

}

/* TMRenderable method */
- (void)render:(float)fDelta
{
    CGRect bounds = [DisplayUtil getDeviceDisplayBounds];

    [super render:fDelta];

    for (int i = 0; i < kNumJudgementValues; ++i)
    {
        [t_JudgeLabels drawFrame:i atPoint:mt_JudgeLabels[i]];
        [m_pJudgeScores[i] drawAtPoint:mt_JudgeScores[i]];
    }

    [t_JudgeLabels drawFrame:kNumJudgementValues atPoint:mt_MaxComboLabel];
    [m_pMaxCombo drawAtPoint:mt_MaxCombo];
    [m_pScore drawAtPoint:mt_Score];
    [t_Grades drawFrame:(int) m_Grade atPoint:mt_Grade];

    [t_Banner drawInRect:mt_Banner];
    [t_overlay drawInRect:bounds];
}

/* TMLogicUpdater stuff */
- (void)update:(float)fDelta
{
    [super update:fDelta];

    if (m_bReturnToSongSelection)
    {
        [[TapMania sharedInstance] switchToScreen:[SongPickerMenuRenderer class] withMetrics:@"SongPickerMenu"];

        m_bReturnToSongSelection = NO;
    }
}

/* TMGameUIResponder methods */
- (BOOL)tmTouchesEnded:(const TMTouchesVec&)touches withEvent:(UIEvent *)event
{
    if (touches.size() == 1)
    {
        m_bReturnToSongSelection = YES;
    }

    return YES;
}


- (TMGrade)gradeFromScore:(long)score fromMaxScore:(long)maxScore
{
    float percent = (float) score / (float) maxScore;

    if (percent >= .95f)
    {
        return kGradeAA;
    }
    else if (percent >= .80f)
    {
        return kGradeA;
    }
    else if (percent >= .70f)
    {
        return kGradeB;
    }
    else if (percent >= .60f)
    {
        return kGradeC;
    }
    else
        return kGradeD;
}


@end
