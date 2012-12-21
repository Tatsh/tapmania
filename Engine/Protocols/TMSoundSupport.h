//
//  $Id$
//  TMEffectSupport.h
//
//  Created by Alex Kremer on 19.08.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

@protocol TMSoundSupport

// This is sent when playback starts on the corresponding queue
- (void)playBackStartedNotification;

// This is sent when the currently playing queue is finished
- (void)playBackFinishedNotification;

@end