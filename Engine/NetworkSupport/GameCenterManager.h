//
//  $Id
//  GameCenterManager.h
//
//  Created by Alex Kremer on 17.01.13.
//  Copyright 2013 Godexsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameCenterManager : NSObject
{
}

@property(nonatomic, retain) NSMutableDictionary *earnedAchievementCache;

+ (GameCenterManager *)sharedInstance;

- (void)authenticateUser;

- (BOOL)supported;

- (void)reportScore:(int)score forDifficulty:(NSNumber *)difficulty basedOnCount:(int)count;

- (void)reportOneShotAchievement:(NSString *)identifier percentComplete:(float)percent;

- (void)reportRecurringAchievement:(NSString *)identifier percentComplete:(float)percent;


@end