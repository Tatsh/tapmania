//
//  $Id$
//  TMMessage.m
//  TapMania
//
//  Created by Alex Kremer on 11.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMMessage.h"


@implementation TMMessage

@synthesize m_pPayload, m_nMessageId;

- (id)initWithId:(int)inId andPayload:(NSObject *)inPayload
{
    self = [super init];
    if (!self)
        return nil;

    m_nMessageId = inId;
    m_pPayload = inPayload;

    return self;
}

@end
