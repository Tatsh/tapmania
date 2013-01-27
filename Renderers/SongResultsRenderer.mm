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
#import "GameCenterManager.h"
#import "PhysicsUtil.h"
#import "TMSound.h"
#import "TMSoundEngine.h"

extern TMGameState *g_pGameState;

@interface SongResultsRenderer (Private)
- (TMGrade)gradeFromScore:(long)score fromMaxScore:(long)maxScore;
@end


@implementation SongResultsRenderer
{
    Texture2D *t_NoBanner;
    BOOL _hasCustomBg;

    float m_nCurrentScore;
    SharedPtr<linear_interpolator> score_interpolator_;

    float m_nCurrentCombo;
    SharedPtr<linear_interpolator> combo_interpolator_;

    float m_nJudgeScoreDisplayCounters[kNumJudgementValues];
    SharedPtr<linear_interpolator> judge_display_interpolators_[kNumJudgementValues];
    Sprite *_gradeSprite;
    TMSound *sr_ScoreCount;
    TMSound *sr_BG;
}
@synthesize sr_BG;


- (void)dealloc
{
    if ( _hasCustomBg )
    {
        [t_BG release];
    }

    // Here we MUST release memory used by the steps since after this place we will not need it anymore
    [g_pGameState->m_pSteps release];
    [g_pGameState->m_pSong release];
    [g_pGameState->m_sMods release];

    g_pGameState->m_pSong = nil;
    g_pGameState->m_pSteps = nil;

    for ( int i = 0; i < kNumJudgementValues; ++i )
    {
        [m_pJudgeScores[i] release];
    }

    [m_pScore release];
    [m_pMaxCombo release];
    g_pGameState->m_nScore = g_pGameState->m_nCombo = 0;

    [_gradeSprite release];
    [sr_BG release];
    [super dealloc];
}

/* TMTransitionSupport methods */
- (void)setupForTransition
{
    [super setupForTransition];

    // sounds
    sr_BG = SOUND(@"SongResults Music");

    // Play music
    [[TMSoundEngine sharedInstance] addToQueue:sr_BG];

    // Textures
    t_JudgeLabels = (TMFramedTexture *) TEXTURE(@"SongResults JudgeLabels");
    t_Grades = (TMFramedTexture *) TEXTURE(@"SongResults Grades");
    t_overlay = TEXTURE(@"SongResults Overlay");
    t_NoBanner = TEXTURE(@"SongResults NoBanner");

    // Sounds
    sr_ScoreCount = SOUND(@"SongResults ScoreCount");

    _hasCustomBg = NO;
    if ( g_pGameState->m_pSong.m_sBackgroundFilePath != nil )
    {
        NSString *songPath = [[SongsDirectoryCache sharedInstance] getSongsPath:g_pGameState->m_pSong.m_iSongsPath];
        NSString *backgroundFilePath = [songPath stringByAppendingPathComponent:g_pGameState->m_pSong.m_sBackgroundFilePath];
        UIImage *img = [UIImage imageWithContentsOfFile:backgroundFilePath];
        if ( img )
        {
            t_BG = [[Texture2D alloc] initWithImage:img columns:1 andRows:1];
            _hasCustomBg = YES;
        }
    }

    self.brightness = 0.5f;

    if ( g_pGameState->m_pSong.bannerTexture != nil )
    {
        t_Banner = g_pGameState->m_pSong.bannerTexture;
    }
    else
    {
        t_Banner = t_NoBanner;
    }

    // Get metrics
    for ( int i = 0; i < kNumJudgementValues; ++i )
    {
        NSString *k = [NSString stringWithFormat:@"SongResults JudgeLabelPositions %d", i];
        mt_JudgeLabels[i] = POINT_METRIC(k);
    }

    for ( int i = 0; i < kNumJudgementValues; ++i )
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
    for ( i = 0; i < kNumJudgementValues; i++ )
    {
        m_nCounters[i] = 0;
    }
    for ( i = 0; i < kNumHoldScores; i++ )
    {
        m_nOkNgCounters[i] = 0;
    }

    // Init grade sprite
    _gradeSprite = [[Sprite alloc] init];
    [_gradeSprite setTexture:t_Grades];

    [_gradeSprite setX:mt_Grade.x];
    [_gradeSprite setY:mt_Grade.y];
    [_gradeSprite setAlpha:0.0f];
    [_gradeSprite setScale:0.01f];

    [_gradeSprite pushKeyFrame:1.4f];

    [_gradeSprite setAlpha:0.0f];
    [_gradeSprite setScale:0.01f];
    [_gradeSprite setRotationZ:360.0f];

    [_gradeSprite pushKeyFrame:0.3f];

    [_gradeSprite setAlpha:0.8f];
    [_gradeSprite setScale:1.6f];
    [_gradeSprite setRotationZ:0.0f];

    [_gradeSprite pushKeyFrame:0.1f];

    [_gradeSprite setAlpha:1.0f];
    [_gradeSprite setScale:1.0f];

    [_gradeSprite startRepeatingBlock];
    [_gradeSprite pushKeyFrame:0.3f];

    [_gradeSprite setRotationZ:-9.0f];
    [_gradeSprite setScale:1.2f];

    [_gradeSprite pushKeyFrame:0.3f];

    [_gradeSprite setRotationZ:0.0f];
    [_gradeSprite setScale:1.0f];

    [_gradeSprite pushKeyFrame:0.3f];

    [_gradeSprite setRotationZ:9.0f];
    [_gradeSprite setScale:1.2f];

    [_gradeSprite pushKeyFrame:0.3f];

    [_gradeSprite setRotationZ:0.0f];
    [_gradeSprite setScale:1.0f];

    [_gradeSprite pushKeyFrame:0.3f];

    [_gradeSprite setRotationZ:-9.0f];
    [_gradeSprite setScale:1.2f];

    [_gradeSprite stopRepeatingBlock];

    m_bReturnToSongSelection = NO;

    // Calculate
    for ( track = 0; track < kNumOfAvailableTracks; track++ )
    {
        int notesCount = [g_pGameState->m_pSteps getNotesCountForTrack:track];

        for ( i = 0; i < notesCount; i++ )
        {
            TMNote *note = [g_pGameState->m_pSteps getNote:i fromTrack:track];

            if ( note.m_nType != kNoteType_Empty )
            {
                m_nCounters[note.m_nScore]++;

                if ( note.m_nType == kNoteType_HoldHead )
                {
                    m_nOkNgCounters[note.m_nHoldScore]++;
                }
            }
        }
    }

    // Create font strings
    for ( int i = 0; i < kNumJudgementValues; ++i )
    {
        if ( i == 6 )
        {
            m_nJudgeScoreDisplayCounters[i] = m_nOkNgCounters[kHoldScore_OK];
            m_pJudgeScores[i] = [[FontString alloc] initWithFont:@"MediumScore"
                                                         andText:@"   0"];
        }
        else
        {
            m_nJudgeScoreDisplayCounters[i] = m_nCounters[i];
            m_pJudgeScores[i] = [[FontString alloc] initWithFont:@"MediumScore"
                                                         andText:@"   0"];
        }

        judge_display_interpolators_[i] = SharedPtr<linear_interpolator>(
                new linear_interpolator(m_nJudgeScoreDisplayCounters[i],
                        0, m_nJudgeScoreDisplayCounters[i], 1.4f));
    }

    m_nCurrentScore = 0;
    score_interpolator_ = SharedPtr<linear_interpolator>(
            new linear_interpolator(m_nCurrentScore,
                    0, g_pGameState->m_nScore, 1.4f));

    m_pScore = [[FontString alloc] initWithFont:@"BigScore"
                                        andText:@"       0"];
    [m_pScore setAlignment:UITextAlignmentCenter];


    m_nCurrentCombo = 0;
    combo_interpolator_ = SharedPtr<linear_interpolator>(
            new linear_interpolator(m_nCurrentCombo,
                    0, g_pGameState->m_nCombo, 1.4f));

    m_pMaxCombo = [[FontString alloc] initWithFont:@"MediumScore"
                                           andText:@"   0"];

    if ( g_pGameState->m_bFailed || g_pGameState->m_bGaveUp )
    {
        m_Grade = kGradeE;

    }
    else if ( m_nCounters[kJudgementW1] == [g_pGameState->m_pSteps getTotalTapAndHoldNotes] )
    {

        m_Grade = kGradeAAAA;
        [[GameCenterManager sharedInstance] reportRecurringAchievement:@"org.tapmania.grade.aaaa" percentComplete:100.0f];
    }
    else if ( m_nCounters[kJudgementW3] == 0 && m_nCounters[kJudgementW4] == 0
            && m_nCounters[kJudgementW5] == 0 && m_nCounters[kJudgementMiss] == 0 )
    {

        m_Grade = kGradeAAA;
        [[GameCenterManager sharedInstance] reportRecurringAchievement:@"org.tapmania.grade.aaa" percentComplete:100.0f];
    }
    else
    {

        m_Grade = [self gradeFromScore:g_pGameState->m_nScore
                          fromMaxScore://[g_pGameState->m_pSteps getDifficultyLevel]*
                                  10000000];

        if ( m_Grade == kGradeAA )
        {
            [[GameCenterManager sharedInstance] reportRecurringAchievement:@"org.tapmania.grade.aa" percentComplete:100.0f];
        }
    }

    // Set grade sprite index
    [_gradeSprite setFrameIndex:m_Grade];

    // Set difficulty and mods display
    [(Label *) [self findControl:@"SongResults DifficultyLabel"] setName:
            [TMSong difficultyToString:g_pGameState->m_nSelectedDifficulty]];

    [(Label *) [self findControl:@"SongResults ModsLabel"] setName:g_pGameState->m_sMods];

    // Save this score if it's better than it was
    NSNumber *diff = [NSNumber numberWithInt:g_pGameState->m_nSelectedDifficulty];
    NSString *sql = [NSString stringWithFormat:@"WHERE hash = '%@' AND difficulty = '%@'", g_pGameState->m_pSong.m_sHash, diff];
    TMSongSavedScore *savedScore = [TMSongSavedScore findFirstByCriteria:sql];

    if ( savedScore != nil )
    {
        TMLog(@"Some old score found: %@", savedScore.bestScore);

        if ( [savedScore.bestScore intValue] < g_pGameState->m_nScore )
        {
            TMLog(@"Better score. Update.");
            savedScore.bestScore = [NSNumber numberWithInt:g_pGameState->m_nScore];
            savedScore.bestGrade = [NSNumber numberWithInt:m_Grade];
            [savedScore save];

            // Reload caches
            [g_pGameState->m_pSong reloadScores];
        }
    }
    else
    {
        TMLog(@"Save score first time!");
        savedScore = [[TMSongSavedScore alloc] init];
        savedScore.hash = g_pGameState->m_pSong.m_sHash;
        savedScore.difficulty = diff;
        savedScore.bestScore = [NSNumber numberWithInt:g_pGameState->m_nScore];
        savedScore.bestGrade = [NSNumber numberWithInt:m_Grade];
        [savedScore save];

        // Reload caches
        [g_pGameState->m_pSong reloadScores];
    }

    if ( [[GameCenterManager sharedInstance] supported] )
    {
        // GameCenter stuff now
        NSString *allSql = [NSString stringWithFormat:@"WHERE difficulty = '%@'", diff];
        NSArray *arr = [TMSongSavedScore findByCriteria:allSql];

        int totalScore = 0;
        int songCount = 0;

        for ( TMSongSavedScore *score in arr )
        {
            ++songCount;
            totalScore += [score.bestScore intValue];
        }

        totalScore /= songCount;
        TMLog(@"Calculated TOTAL SCORE (based on %d songs): %d", songCount, totalScore);

        [[GameCenterManager sharedInstance] reportScore:totalScore forDifficulty:diff basedOnCount:songCount];
    }

    if ( !g_pGameState->m_bFailed && !g_pGameState->m_bGaveUp )
    {
        [[GameCenterManager sharedInstance] reportOneShotAchievement:@"org.tapmania.play.first" percentComplete:100.0f];
    }

    // Score count sound effect
    [[TMSoundEngine sharedInstance] playEffect:sr_ScoreCount];
}

/* TMRenderable method */
- (void)render:(float)fDelta
{
    CGRect bounds = [DisplayUtil getDeviceDisplayBounds];

    [super render:fDelta];

    for ( int i = 0; i < kNumJudgementValues; ++i )
    {
        [t_JudgeLabels drawFrame:i atPoint:mt_JudgeLabels[i]];
        [m_pJudgeScores[i] drawAtPoint:mt_JudgeScores[i]];
    }

    [t_JudgeLabels drawFrame:kNumJudgementValues atPoint:mt_MaxComboLabel];
    [m_pMaxCombo drawAtPoint:mt_MaxCombo];
    [m_pScore drawAtPoint:mt_Score];
    [_gradeSprite render:fDelta];

    [t_Banner drawInRect:mt_Banner];
    [t_overlay drawInRect:bounds];
}

/* TMLogicUpdater stuff */
- (void)update:(float)fDelta
{
    [super update:fDelta];

    // Update the grade animation
    [_gradeSprite update:fDelta];

    // Update the score
    if ( !score_interpolator_.get()->finished() )
    {
        score_interpolator_.get()->update(fDelta);
        [m_pScore updateText:[NSString stringWithFormat:@"%8d", (int) m_nCurrentScore]];
    }

    // Update the combo
    if ( !combo_interpolator_.get()->finished() )
    {
        combo_interpolator_.get()->update(fDelta);
        [m_pMaxCombo updateText:[NSString stringWithFormat:@"%4d", (int) m_nCurrentCombo]];
    }

    // Update all judgements
    for ( int i = 0; i < kNumJudgementValues; ++i )
    {
        if ( !judge_display_interpolators_[i].get()->finished() )
        {
            judge_display_interpolators_[i].get()->update(fDelta);
            [m_pJudgeScores[i] updateText:[NSString stringWithFormat:@"%4d", (int) m_nJudgeScoreDisplayCounters[i]]];
        }
    }

    if ( m_bReturnToSongSelection )
    {
        [[TapMania sharedInstance] switchToScreen:[SongPickerMenuRenderer class] withMetrics:@"SongPickerMenu"];

        m_bReturnToSongSelection = NO;
    }
}

/* TMGameUIResponder methods */
- (BOOL)tmTouchesEnded:(const TMTouchesVec&)touches withEvent:(UIEvent *)event
{
    if ( touches.size() == 1 )
    {
        m_bReturnToSongSelection = YES;
    }

    return YES;
}


- (TMGrade)gradeFromScore:(long)score fromMaxScore:(long)maxScore
{
    float percent = (float) score / (float) maxScore;

    if ( percent >= .95f )
    {
        return kGradeAA;
    }
    else if ( percent >= .80f )
    {
        return kGradeA;
    }
    else if ( percent >= .70f )
    {
        return kGradeB;
    }
    else if ( percent >= .60f )
    {
        return kGradeC;
    }
    else
    {
        return kGradeD;
    }
}


@end
