//
//  $Id
//  GameCenterManager.mm
//
//  Created by Alex Kremer on 17.01.13.
//  Copyright 2013 Godexsoft. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "GameCenterManager.h"
#import "DisplayUtil.h"

@implementation GameCenterManager
{

}

@synthesize earnedAchievementCache = _earnedAchievementCache;

+ (GameCenterManager *)sharedInstance
{
    static GameCenterManager *_instance = nil;

    @synchronized ( self )
    {
        if ( _instance == nil )
        {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (void)authenticateUser
{
    if ( ![self supported] )
    {
        TMLog(@"Gamekit not supported. Not doing anything.");
        return;
    }

    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    [localPlayer authenticateWithCompletionHandler:
            ^(NSError *error)
            {
                if ( localPlayer.isAuthenticated )
                {
                    // Player was successfully authenticated.
                    // Perform additional tasks for the authenticated player.
                    TMLog(@"Player now authenticated: %@", localPlayer.alias);
                }
                else
                {
                    // Check the error
                    if ( error.code == GKErrorNotSupported )
                    {
                        TMLog(@"Device doesn't support GameKit - give up forever.");
                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"TapmaniaSupportGamekit"];
                    }
                    else
                    {
                        TMLog(@"User just cancelled GameKit authentication.");
                    }
                }
            }
    ];
}

- (BOOL)supported
{
    NSNumber *supported = [[NSUserDefaults standardUserDefaults] objectForKey:@"TapmaniaSupportGamekit"];
    if ( supported )
    {
        return [supported boolValue];
    }

    return YES; // May be overwritten later
}

- (void)reportScore:(int)score forDifficulty:(NSNumber *)difficulty basedOnCount:(int)count
{
    if ( ![self supported] )
    {
        TMLog(@"Not reporting score as GameKit is not supported.");
        return;
    }

    TMLog(@"Want to report %d score for diff %d based on count %d", score, [difficulty intValue], count);

    NSString *category = [NSString stringWithFormat:@"org.tapmania.leaderboard.%@.%d", [DisplayUtil getDeviceTypeString], [difficulty intValue]];
    GKScore *s = [[[GKScore alloc] initWithCategory:category] autorelease];

    s.value = score;

    [s reportScoreWithCompletionHandler:^(NSError *error)
    {
        TMLog(@"Score is reported!");
    }];
}

- (void)reportOneShotAchievement:(NSString *)identifier percentComplete:(float)percent
{
    if ( self.earnedAchievementCache == NULL )
    {
        [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *scores, NSError *error)
        {
            if ( error == NULL )
            {

                NSMutableDictionary *tempCache = [NSMutableDictionary dictionaryWithCapacity:[scores count]];
                for ( GKAchievement *score in scores )
                {
                    [tempCache setObject:score forKey:score.identifier];
                }

                self.earnedAchievementCache = tempCache;
                [self reportOneShotAchievement:identifier percentComplete:percent];
            }
        }];
    }
    else
    {
        GKAchievement *achievement = [self.earnedAchievementCache objectForKey:identifier];
        if ( achievement != NULL )
        {
            if ( (achievement.percentComplete >= 100.0) || (achievement.percentComplete >= percent) )
            {
                achievement = NULL;
            }

            achievement.percentComplete = percent;
        }
        else
        {
            achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
            achievement.percentComplete = percent;

            [self.earnedAchievementCache setObject:achievement forKey:achievement.identifier];
        }
        if ( achievement != NULL )
        {
            if ( achievement.percentComplete >= 100 )
            {
                if ( [achievement respondsToSelector:@selector(setShowsCompletionBanner:)] )
                {
                    [achievement setShowsCompletionBanner:YES];
                }
            }

            [achievement reportAchievementWithCompletionHandler:^(NSError *error)
            {
                if ( error != NULL )
                {
                    TMLog(@"Error in reporting achievements: %@", error);
                }
            }];
        }
    }
}

- (void)reportRecurringAchievement:(NSString *)identifier percentComplete:(float)percent
{
    GKAchievement *achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
    achievement.percentComplete = percent;
    if ( [achievement respondsToSelector:@selector(setShowsCompletionBanner:)] )
    {
        [achievement setShowsCompletionBanner:YES];
    }

    [achievement reportAchievementWithCompletionHandler:^(NSError *error)
    {
        if ( error != NULL )
        {
            TMLog(@"Error in reporting achievements: %@", error);
        }
    }];
}

- (void)dealloc
{
    [_earnedAchievementCache release];
    [super dealloc];
}

@end