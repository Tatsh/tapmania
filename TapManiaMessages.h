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
	
	/* Gameplay messages */
	kLifeBarDrainedMessage = 200,			/* Sent by LifeBar when the lifebar is drained */
	kReceptorShouldExplodeDimMessage,		/* Sent by gameplay handler to receptorRow handler. payload = track number */
	kReceptorShouldExplodeBrightMessage	/* Same as above */
};