//
//  $Id$
//  MessageManager.m
//  TapMania
//
//  Created by Alex Kremer on 11.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "MessageManager.h"
#import "TMMessageSupport.h"
#import "TMMessage.h"

// This is a singleton class, see below
static MessageManager *sharedMessageManagerDelegate = nil;

@interface MessageManager (Private)
- (BOOL)messageTypeIsRegistered:(int)inId;

- (NSString *)messageNameFromId:(int)inId;
@end

@implementation MessageManager

- (id)init
{
    self = [super init];
    if (!self)
        return nil;

    // m_pMessageQueue = new TMMessageQueue();
    m_pRegistrature = new TMMessageMapping();
    m_pSubscribers = new TMMessageSubscribers();

    return self;
}

- (void)dealloc
{
    // delete m_pMessageQueue;
    delete m_pRegistrature;
    delete m_pSubscribers;

    [super dealloc];
}


- (int)broadcastMessage:(TMMessage *)message
{

//	@synchronized(self) {
    // Don't check for message id because can slow down the system
    if (m_pSubscribers->empty())
        return 0;

    int subscribersCount = m_pSubscribers->count(message.messageId);

    if (subscribersCount > 0)
    {
        TMMessageSubscribers::iterator it;
        for (it = m_pSubscribers->equal_range(message.messageId).first; it != m_pSubscribers->equal_range(message.messageId).second; ++it)
        {
            [(id <TMMessageSupport>) ((*it).second) handleMessage:message];
        }
    }

    [message release];
    return subscribersCount;
//	}

    return 0;
}

- (BOOL)subscribe:(NSObject *)inClass forMessagesWithId:(int)inMessageId
{

    if (![self messageTypeIsRegistered:inMessageId])
    {
        TMLog(@"Attempt to subscribe '%@' for message id '%d' which is not registered in the system.", inClass, inMessageId);
        return NO;
    }

    //@synchronized(self) {

    if (!m_pSubscribers->empty() && m_pSubscribers->count(inMessageId) > 0)
    {
        // Check whether the given class is already subscribed to the requested message

        TMMessageSubscribers::iterator it;
        for (it = m_pSubscribers->equal_range(inMessageId).first; it != m_pSubscribers->equal_range(inMessageId).second; ++it)
        {
            if (((*it).second) == inClass)
            {
                TMLog(@"Attempt to double-subscribe '%@' object to '%@' message. aborting.", inClass, [self messageNameFromId:inMessageId]);
                return NO;
            }
        }
    }

    // Ok, subscribe
    m_pSubscribers->insert(pair<int, NSObject *>(inMessageId, inClass));
    TMLog(@"Subscribe '%@' for message '%@'. success.", inClass, [self messageNameFromId:inMessageId]);
    //}

    return YES;
}

- (void)unsubscribe:(NSObject *)inClass fromMessagesWithId:(int)inMessageId
{
//	@synchronized(self) {
    if (m_pSubscribers->count(inMessageId) > 0)
    {
        TMMessageSubscribers::iterator it;
        for (it = m_pSubscribers->equal_range(inMessageId).first; it != m_pSubscribers->equal_range(inMessageId).second; ++it)
        {
            if (((*it).second) == inClass)
            {
                m_pSubscribers->erase(it);
                return;
            }
        }
    }
//	}
}

- (void)unsubscribe:(NSObject *)inClass
{
//	@synchronized(self) {
    TMMessageSubscribers tmp;
    TMMessageSubscribers::iterator it;

    for (it = m_pSubscribers->begin(); it != m_pSubscribers->end(); ++it)
    {
        if (((*it).second) == inClass)
        {
            tmp.insert(std::make_pair((*it).first, (*it).second));
        }
    }

    for (it = tmp.begin(); it != tmp.end(); ++it)
    {
        TMMessageSubscribers::iterator jit;
        for (jit = m_pSubscribers->equal_range((*it).first).first;
             jit != m_pSubscribers->equal_range((*it).first).second;
             ++jit)
        {
            if (((*jit).second) == inClass)
            {
                m_pSubscribers->erase(jit);
                break; // fro the inner for loop
            }
        }
    }
//	}	
}

- (BOOL)registerMessageName:(NSString *)inName forMessageId:(int)inId
{
    // Check whether this id is already registred
    if ([self messageTypeIsRegistered:inId])
    {
        TMLog(@"Attempt to register a new message '%@' with id '%d' which is already used for another message type.", inName, inId);
        return NO;
    }

//	@synchronized(self) {	
    // Allow to register it
    m_pRegistrature->insert(pair<int, NSString *>(inId, inName));
    TMLog(@"New message type '%@' registered under id '%d'.", inName, inId);
//	}

    return YES;
}

// Private methods
- (BOOL)messageTypeIsRegistered:(int)inId
{
//	@synchronized(self) {
    if (!m_pRegistrature->empty() && m_pRegistrature->count(inId) > 0)
        return YES;
//	}

    return NO;
}

- (NSString *)messageNameFromId:(int)inId
{
    if ([self messageTypeIsRegistered:inId])
    {
//		@synchronized(self) { 
        return m_pRegistrature->find(inId)->second;
//		}
    }

    return @"Message_Not_Registered";
}

#pragma mark Singleton stuff
+ (MessageManager *)sharedInstance
{
    @synchronized (self)
    {
        if (sharedMessageManagerDelegate == nil)
        {
            [[self alloc] init];
        }
    }
    return sharedMessageManagerDelegate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized (self)
    {
        if (sharedMessageManagerDelegate == nil)
        {
            sharedMessageManagerDelegate = [super allocWithZone:zone];
            return sharedMessageManagerDelegate;
        }
    }

    return nil;
}


- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release
{
    // NOTHING
}

- (id)autorelease
{
    return self;
}

@end
