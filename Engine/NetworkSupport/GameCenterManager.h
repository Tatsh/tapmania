//
//  $Id
//  GameCenterManager.h
//
//  Created by Alex Kremer on 17.01.13.
//  Copyright 2013 Godexsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMSong;
@interface GameCenterManager : NSObject
{
}

@property(nonatomic, retain) NSMutableDictionary *earnedAchievementCache;

+ (GameCenterManager *)sharedInstance;

- (void)authenticateUser;

- (BOOL)supported;

- (void)reportOneShotAchievement:(NSString *)identifier percentComplete:(float)percent;

- (void)reportRecurringAchievement:(NSString *)identifier percentComplete:(float)percent;

- (void)reportScore:(long)i forSong:(TMSong *)song;

@end