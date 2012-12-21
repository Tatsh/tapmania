//
//  $Id$
//  MessageManager.h
//  TapMania
//
//  Created by Alex Kremer on 11.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

@class TMMessage;

#define REG_MESSAGE(ident,name)                [[MessageManager sharedInstance] registerMessageName:name forMessageId:ident]
#define BROADCAST_MESSAGE(msgId,payload)    [[MessageManager sharedInstance] broadcastMessage:[[TMMessage alloc] initWithId:msgId andPayload:payload]]
#define SUBSCRIBE(ident)                    [[MessageManager sharedInstance] subscribe:self forMessagesWithId:ident];
#define UNSUBSCRIBE_ALL()                    [[MessageManager sharedInstance] unsubscribe:self];

#ifdef __cplusplus

#include <queue>
#include <map>

using namespace std;

typedef queue<TMMessage *> TMMessageQueue;
typedef map<int, NSString *> TMMessageMapping;
typedef multimap<int, NSObject *> TMMessageSubscribers;

#endif

@interface MessageManager : NSObject
{
#ifdef __cplusplus
    // TMMessageQueue			*m_pMessageQueue; // TODO: use this queue in a separate thread for async messages
    TMMessageMapping *m_pRegistrature;
    TMMessageSubscribers *m_pSubscribers;
#endif
}

// Returns count of recepients
- (int)broadcastMessage:(TMMessage *)message;

// Subscribe/unsubscribe 
- (BOOL)subscribe:(NSObject *)inClass forMessagesWithId:(int)inMessageId;

- (void)unsubscribe:(NSObject *)inClass fromMessagesWithId:(int)inMessageId;

- (void)unsubscribe:(NSObject *)inClass;

// Register message id->name
- (BOOL)registerMessageName:(NSString *)inName forMessageId:(int)inId;

+ (MessageManager *)sharedInstance;

@end
