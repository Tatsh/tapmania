//
//  $Id$
//  SongResultsRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 21.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "TMNote.h" // For kNumNoteScores etc.

#import "TMScreen.h"

#define kMaximumScore 10000000l
@class TMSteps, TMSong, FontString, TMFramedTexture;
@class TMSound;


typedef enum
{
    kGradeAAAA = 0,
    kGradeAAA,
    kGradeAA,
    kGradeA,
    kGradeB,
    kGradeC,
    kGradeD,
    kGradeE,
    kNumOfGrades
} TMGrade;


@interface SongResultsRenderer : TMScreen
{
    int m_nCounters[kNumJudgementValues];
    int m_nOkNgCounters[kNumHoldScores];

    BOOL m_bReturnToSongSelection;

    FontString *m_pJudgeScores[kNumJudgementValues];
    FontString *m_pScore;
    FontString *m_pMaxCombo;

    TMGrade m_Grade;

    // Metrics and cache
    CGPoint mt_JudgeLabels[kNumJudgementValues];
    CGPoint mt_JudgeScores[kNumJudgementValues];

    CGPoint mt_MaxCombo, mt_MaxComboLabel;
    CGPoint mt_Score;
    CGPoint mt_Grade;
    CGRect mt_Banner;

    Texture2D *t_overlay;
    TMFramedTexture *t_JudgeLabels;
    TMFramedTexture *t_Grades;
    Texture2D *t_Banner;
}
@property(nonatomic, retain) TMSound *sr_BG;


@end
