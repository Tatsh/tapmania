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
#import "TMSong.h"
#import <vector>
#import <string>

@implementation GameCenterManager
{

    std::vector<std::string> supported_songs_;
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

- (id) init
{
    self = [super init];
    if (self)
    {
        supported_songs_.push_back("1b5e63ec2b9ec4bd8df96264b5916ad3");
        supported_songs_.push_back("1ee8020e445d37190f76ee7fb17a1864");
        supported_songs_.push_back("85ecd7805035b28812df715425afd5ef");
        supported_songs_.push_back("1ab5c56eb03d559e8a1c008e3cd3a278");
        supported_songs_.push_back("d537889e79199f2e587ca50f062fdc7d");
        supported_songs_.push_back("2587ac8fc078b98f8f0a7d5cb31f7587");
        supported_songs_.push_back("4e744f293a382c0be5dd5de341284435");
        supported_songs_.push_back("c4b6d67f85d34ab6283169796b5e5985");
        supported_songs_.push_back("2652cd4526ce5f1fc688562c5e8e6e31");
        supported_songs_.push_back("d4f5e903af41eb860f1652bbf32acf00");
        supported_songs_.push_back("68ec8dfa9191256e1844ffc9c723ffe3");
        supported_songs_.push_back("2e7ec12f09eadfd61ba5a86e65843f5a");
    }
    return self;
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

- (void)reportScore:(long)score forSong:(TMSong *)song
{
    if ( ![self supported] )
    {
        TMLog(@"Not reporting score as GameKit is not supported.");
        return;
    }

    TMLog(@"Check if can report to '%@'", song.m_sHash);
    if ( std::find(supported_songs_.begin(),
            supported_songs_.end(),
            song.m_sHash.UTF8String) != supported_songs_.end() )
    {
        NSString *category = [NSString stringWithFormat:@"org.tapmania.leaderboard.%@.song.%@",
                        [DisplayUtil getDeviceTypeString], song.m_sHash];


        TMLog(@"\n\n\n\nREPORT FOR '%@'\n\n\n\n", category);
        GKScore *s = [[[GKScore alloc] initWithCategory:category] autorelease];

        s.value = score;

        [s reportScoreWithCompletionHandler:^(NSError *error)
        {
            TMLog(@"Score is reported!");
        }];
    }
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