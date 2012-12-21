//
//  $Id$
//  PadConfigRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 6/16/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMScreen.h"

#import "TMSteps.h"

@class TMRunLoop, ReceptorRow, LifeBar, MenuItem, Vector, Texture2D, TMFramedTexture, TapNote;

typedef enum
{
    kPadConfigAction_None = 0,
    kPadConfigAction_SelectedTrack,
    kPadConfigAction_SelectLocation,
    kPadConfigAction_SelectedLocation,
    kPadConfigAction_Reset,
    kPadConfigAction_Exit,
    kNumPadConfigActions
} TMPadConfigActions;

@interface PadConfigRenderer : TMScreen
{
    Vector *m_pFingerTap[kNumOfAvailableTracks];

    ReceptorRow *m_pReceptorRow;
    LifeBar *m_pLifeBar;
    MenuItem *m_pResetButton;

    TMPadConfigActions m_nPadConfigAction;
    TMAvailableTracks m_nSelectedTrack;

    /* Metrics and such */
    TMFramedTexture *t_FingerTap;

    TapNote *t_TapNote;

    CGRect mt_ReceptorButtons[kNumOfAvailableTracks];
    CGRect mt_LifeBar, mt_ResetButton;
}

@end
