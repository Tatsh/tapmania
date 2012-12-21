//
//  $Id$
//  NewsFetcher.h
//  TapMania
//
//  Created by Alex Kremer on 8/11/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NewsFetcher : NSObject
{
    BOOL m_bGotNews;
    BOOL m_bRunning;
    BOOL m_bCheck;
    NSString *m_sNews;
    NSString *m_sNewsVersion;

    NSThread *m_pThread;
}

- (BOOL)hasUnreadNews;

- (NSString *)getUnreadNews;

- (void)stopChecking;

- (void)startChecking;

+ (NewsFetcher *)sharedInstance;

@end
