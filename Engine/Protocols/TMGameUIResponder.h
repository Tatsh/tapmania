//
//  $Id$
//  TMGameUIResponder.h
//  TapMania
//
//  Created by Alex Kremer on 3.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#include "TMTouch.h"

// This protocol must be implemented by ui input handlers which wish to receive input events
@protocol TMGameUIResponder

// All methods are optional
@required
- (BOOL)tmTouchesBegan:(const TMTouchesVec&)touches withEvent:(UIEvent *)event;

- (BOOL)tmTouchesMoved:(const TMTouchesVec&)touches withEvent:(UIEvent *)event;

- (BOOL)tmTouchesEnded:(const TMTouchesVec&)touches withEvent:(UIEvent *)event;

@end
