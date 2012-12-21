//
//  $Id$
//  TMMessage.h
//  TapMania
//
//  Created by Alex Kremer on 11.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

@interface TMMessage : NSObject
{
    int m_nMessageId;

    NSObject *m_pPayload;
}

@property(retain, nonatomic, readonly, getter=payload) NSObject *m_pPayload;
@property(assign, nonatomic, readonly, getter=messageId) int m_nMessageId;

- (id)initWithId:(int)inId andPayload:(NSObject *)inPayload;

@end
