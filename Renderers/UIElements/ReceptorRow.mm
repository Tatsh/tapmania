//
//  $Id$
//  ReceptorRow.m
//  TapMania
//
//  Created by Alex Kremer on 05.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "ReceptorRow.h"
#import "Texture2D.h"
#import "ThemeManager.h"
#import "TMNote.h"
#import "TMMessage.h"
#import "TMSound.h"
#import "TMSoundEngine.h"
#import "MessageManager.h"
#import "Sprite.h"
#import "GameState.h"
#import "TimingUtil.h"

extern TMGameState *g_pGameState;

@implementation ReceptorRow

- (id)init
{
    self = [super init];
    if (!self)
        return nil;

    // Subscribe to messages
    SUBSCRIBE(kJoyPadTapMessage);
    SUBSCRIBE(kNoteScoreMessage);

    mt_ReceptorExplosionMaxShowTime = FLOAT_SKIN_METRIC(@"ReceptorRow Explosion MaxShowTime");

    // Cache textures
    t_Receptor = SKIN_TEXTURE(@"DownReceptor");
    t_ExplosionDim = SKIN_TEXTURE(@"DownTapExplosionDim");
    t_ExplosionBright = SKIN_TEXTURE(@"DownTapExplosionBright");
    t_MineExplosion = SKIN_TEXTURE(@"HitMineExplosion");

    // Cache metrics
    for (int i = 0; i < kNumOfAvailableTracks; ++i)
    {
        mt_Receptors[i] = RECT_SKIN_METRIC(([NSString stringWithFormat:@"ReceptorRow %d", i]));
        mt_ReceptorExplosions[i] = RECT_SKIN_METRIC(([NSString stringWithFormat:@"ReceptorRow Explosion %d", i]));
        mt_ReceptorRotations[i] = FLOAT_SKIN_METRIC(([NSString stringWithFormat:@"ReceptorRow Rotation %d", i]));
        mt_ReceptorExplosionRotations[i] = FLOAT_SKIN_METRIC(([NSString stringWithFormat:@"ReceptorRow Explosion Rotation %d", i]));

        m_dExplosionTime[i] = 0.0f;
        m_nExplosion[i] = kExplosionTypeNone;

        float x = mt_Receptors[i].origin.x + mt_Receptors[i].size.width / 2;
        float y = mt_Receptors[i].origin.y + mt_Receptors[i].size.height / 2;
        {
            Sprite *spr = [[Sprite alloc] init];
            [spr setTexture:t_Receptor];
            [spr setX:x];
            [spr setY:y];
            [spr setRotationZ:mt_ReceptorRotations[i]];
            m_spriteReceptor[i] = spr;
        }
        {
            // Load up the Dim explosion sprite
            Sprite *spr = [[Sprite alloc] init];
            [spr setTexture:t_ExplosionDim];
            [spr setAlpha:0];
            [spr setX:x];
            [spr setY:y];
            [spr setRotationZ:mt_ReceptorRotations[i]];
            m_spriteExplosionDim[i] = spr;
        }
        {
            Sprite *spr = [[Sprite alloc] init];
            [spr setTexture:t_ExplosionBright];
            [spr setAlpha:0];
            [spr setX:x];
            [spr setY:y];
            [spr setRotationZ:mt_ReceptorRotations[i]];
            m_spriteExplosionBright[i] = spr;
        }
        {
            Sprite *spr = [[Sprite alloc] init];
            [spr setTexture:t_MineExplosion];
            [spr setAlpha:0];
            [spr setX:x];
            [spr setY:y];
            [spr setRotationZ:mt_ReceptorRotations[i]];
            m_spriteMineExplosion[i] = spr;
        }
    }

    // Sounds
    sr_ExplosionMine = SOUND(@"SongPlay HitMine");

    return self;
}

- (void)dealloc
{
    UNSUBSCRIBE_ALL();
    for (int i = 0; i < kNumOfAvailableTracks; ++i)
    {
        [m_spriteExplosionDim[i] release];
        [m_spriteExplosionBright[i] release];
    }
    [super dealloc];
}

- (void)buttonTap:(TMAvailableTracks)track
{
    Sprite *spr = m_spriteReceptor[track];
    [spr finishKeyFrames];
    [spr setScale:0.6];
    [spr pushKeyFrame:0.3];
    [spr setScale:1];
}

- (void)tapNoteExplodeTrack:(TMAvailableTracks)track bright:(bool)bright judgement:(TMJudgement)judgement
{
    int i = track;
    Sprite *spr = bright ? m_spriteExplosionBright[i] : m_spriteExplosionDim[i];
    [spr finishKeyFrames];
    [spr setScale:1.05];    // TODO: Remove this and change the graphic
    [spr setAlpha:1];
    // TODO: Remove hard-coded colors
    float r, g, b;
    switch (judgement)
    {
        default:
            assert(0);
        case kJudgementW1:
            r = 1;
            g = 1;
            b = 1;
            break;
        case kJudgementW2:
            r = 1;
            g = 1;
            b = 0;
            break;
        case kJudgementW3:
            r = 0.2;
            g = 1;
            b = 0.2;
            break;
        case kJudgementW4:
            r = 0;
            g = 0.9;
            b = 1;
            break;
        case kJudgementW5:
            r = 1;
            g = 0.2;
            b = 0.8;
            break;
    }
    [spr setR:r G:g B:b];
    [spr pushKeyFrame:0.3];
    [spr setAlpha:0];
}

- (void)explodeMine:(TMAvailableTracks)track
{
    // TODO: make keyframing rotate
    Sprite *spr = m_spriteExplosionBright[track];
    [spr finishKeyFrames];
    [spr setScale:1.05];
    [spr setAlpha:1];
    [spr pushKeyFrame:0.3];
    [spr setAlpha:0];
}

/* TMRenderable method */
- (void)render:(float)fDelta
{

    float currentBeat, currentBps;
    BOOL hasFreeze;
    float brightness = 1.0f;

    if (g_pGameState->m_bPlayingGame)
    {
        [TimingUtil getBeatAndBPSFromElapsedTime:g_pGameState->m_dElapsedTime beatOut:&currentBeat bpsOut:&currentBps freezeOut:&hasFreeze inSong:g_pGameState->m_pSong];
        float beatFraction = currentBeat - floorf(currentBeat);
        brightness = (beatFraction > 0.9 || beatFraction < 0.1) ? 1.0f : 0.5f;
    }

    // Here we will render all receptors at their places
    for (int i = 0; i < kNumOfAvailableTracks; ++i)
    {
        // Dark mod disables the receptor row but not the explosions
        if (!g_pGameState->m_bModDark)
        {
            if (g_pGameState->m_bPlayingGame)
                [m_spriteReceptor[i] setR:brightness G:brightness B:brightness];
            [m_spriteReceptor[i] render:fDelta];
        }

        [m_spriteExplosionDim[i] render:fDelta];
        [m_spriteExplosionBright[i] render:fDelta];
        [m_spriteMineExplosion[i] render:fDelta];
    }
}

/* TMLogicUpdater method */
- (void)update:(float)fDelta
{
}

/* TMMessageSupport stuff */
- (void)handleMessage:(TMMessage *)message
{
    switch (message.messageId)
    {
        case kJoyPadTapMessage:
        {
            NSNumber *joyPad = (NSNumber *) message.payload;
            int joyPad2 = [joyPad intValue];
            if (joyPad2 < kNumOfAvailableTracks)
            {
                TMAvailableTracks track2 = (TMAvailableTracks) joyPad2;
                [self buttonTap:track2];
            }
        }
            break;
        case kNoteScoreMessage:
            TMNote *note = (TMNote *) message.payload;

            if (note.m_nType == kNoteType_Mine)
            {
                [self explodeMine:note.m_nTrack];
                [[TMSoundEngine sharedInstance] playEffect:sr_ExplosionMine];
            } else
            {
                // TODO: apply color to the exlosion depending on the score?
                switch (note.m_nScore)
                {
                    case kJudgementW1:
                    case kJudgementW2:
                    case kJudgementW3:
                    case kJudgementW4:
                    case kJudgementW5:
                        // flash bright if combo over certain threshold
                        // TODO: move threshold to some configurable place
                        TMLog(@"Current combo: %d", g_pGameState->m_nCombo);
                        bool bright = g_pGameState->m_nCombo >= 100;
                        [self tapNoteExplodeTrack:note.m_nTrack bright:bright judgement:note.m_nScore];
                        break;
                }
            }

            break;
    }
}

@end
