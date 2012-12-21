//
//  $Id$
//  TMTransition.h
//  TapMania
//
//  Created by Alex Kremer on 11.02.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

@protocol TMTransition

- (void)transitionInStarted;

- (void)transitionOutStarted;

- (void)transitionInFinished;

- (void)transitionOutFinished;

@end
