/*
 *  TapManiaMessages.h
 *  TapMania
 *
 *  Created by Alex Kremer on 11.09.09.
 *  Copyright 2009 Godexsoft. All rights reserved.
 *
 */

enum {
	/* Global messages */
	kApplicationStartedMessage = 1,
	kApplicationShouldTerminateMessage,
	
	/* Joypad */
	kJoyPadActivityMessage = 100,			/* Sent when user taps somewhere in the joypad */
	
	/* Gameplay messages */
	kGamePlayStartedMessage = 200,			/* Sent when song starts */
	kGamePlayFinishedMessage,				/* Sent when song finished (cleared, exit requested or failed) */
	
	kNoteHitMessage,						/* Sent when user hits a note; payload = note */
	kNoteLostMessage,						/* Sent when user lost a note; payload = note */
	kHoldHeldMessage, kHoldLostMessage		/* Hold is held/lost messages; payload = holdnote */
	kMineHitMessage, kMineAvoidedMessage,   /* Mine hit/avoided messages; payload = mine */
	
	kLifeBarDrainedMessage,					/* Sent by LifeBar when the lifebar is drained */
	
	kReceptorShouldExplodeDimMessage,		/* Sent by gameplay handler to receptorRow handler. payload = track number */
	kReceptorShouldExplodeBrightMessage		/* Same as above */
};