/*
 *  $Id$
 *  TapManiaMessages.h
 *
 *  Created by Alex Kremer on 11.09.09.
 *  Copyright 2009 Godexsoft. All rights reserved.
 *
 */

enum
{
    /* Global messages */
    kApplicationStartedMessage = 1,
    kApplicationShouldTerminateMessage,

    /* Joypad */
    kJoyPadTapMessage = 100,    /* Sent when user taps somewhere in the joypad; payload = button id */
    kJoyPadReleaseMessage,      /* The same for release */

    /* Gameplay messages */
    kGamePlayStartedMessage = 200,  /* Sent when song starts */
    kGamePlayFinishedMessage,       /* Sent when song finished (cleared, exit requested or failed) */

    kNoteScoreMessage,                      /* Sent when user scores on a note; payload = note */
    kHoldHeldMessage, kHoldLostMessage,     /* Hold is held/lost messages; payload = holdnote */
    kMineHitMessage, kMineAvoidedMessage,   /* Mine hit/avoided messages; payload = mine */

    kLifeBarDrainedMessage,                 /* Sent by LifeBar when the lifebar is drained */
    kLifeBarWarningMessage,                 /* Sent by LifeBar when the player is close to fail */
    kLifeBarBackNormalMessage,              /* Sent by LifeBar when the lifebar is recovered from the above */
};