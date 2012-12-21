//
//  $Id$
//  TMMessageSupport.h
//
//  Created by Alex Kremer on 11.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

@class TMMessage;

@protocol TMMessageSupport
- (void)handleMessage:(TMMessage *)message;
@end