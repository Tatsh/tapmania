//
//  TMGameUIResponder.h
//  TapMania
//
//  Created by Alex Kremer on 3.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

// This protocol must be implemented by ui input handlers which wish to receive input events
@protocol TMGameUIResponder 

// All methods are optional
@required
- (BOOL) tmTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;
- (BOOL) tmTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event;
- (BOOL) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;

@end
