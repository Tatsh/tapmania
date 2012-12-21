//
//  $Id$
//  TMTransitionSupport.h
//
//  Created by Alex Kremer on 3.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

@protocol TMTransitionSupport

@required
- (void)setupForTransition;

- (void)deinitOnTransition;

@optional
- (void)beforeTransition;

- (void)afterTransition;

@end