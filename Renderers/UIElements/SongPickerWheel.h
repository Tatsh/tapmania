//
//  $Id$
//  SongPickerWheel.h
//  TapMania
//
//  Created by Alex Kremer on 23.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMControl.h"
#import "TMSong.h"

#define kNumSwipePositions 10

@class SongPickerMenuItem, Texture2D, FontString;

#ifdef __cplusplus

#include <deque>
#include "ObjCPtr.h"
#import "iCadeState.h"
#import "JoyPad.h"
#import "ICadeResponder.h"

typedef ObjCPtr<SongPickerMenuItem> TMWheelItemPtr;
typedef deque<TMWheelItemPtr> TMWheelItems;
#endif

@class TMFramedTexture;

@interface SongPickerWheel : TMControl <ICadeResponder>
{
#ifdef __cplusplus
    TMWheelItems *m_pWheelItems;
#endif

    int m_nCurrentScoreDisplayed;

    /* Metrics and such */
    CGRect mt_ItemSong;
    int mt_ItemSongHalfHeight;

    CGPoint mt_ScoreDisplay;
    CGPoint mt_ScoreFrame;

    CGRect mt_HighlightCenter;
    CGRect mt_Highlight;
    int mt_HighlightHalfHeight;
    float mt_wheelTopTouchZone;

    TMFramedTexture *t_Highlight;
    Texture2D *t_ScoreFrame;
    FontString *m_pScoreStr;

    int mt_SelectedWheelItemId;
    int mt_NumWheelItems;
    float mt_DistanceBetweenItems;
    float mt_SelectedItemCenterY;

    id m_idMusicPlaybackDelegate;
    SEL m_oMusicPlaybackHandler;
}

@property(assign, nonatomic) BOOL songChanged;

- (SongPickerMenuItem *)getSelected;

- (void)updateAllWithDifficulty:(TMSongDifficulty)diff;

- (void)setCurrentBps:(float)bps;

- (void)updateScore;

- (void)setMusicPlaybackHandler:(SEL)pSelector receiver:(id)receiver;
@end
