//
//  $Id$
//  TMSound.m
//  TapMania
//
//  Created by Alex Kremer on 19.08.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMSound.h"
#import "TMSoundEngine.h"

#import "AbstractSoundPlayer.h"
#import "OGGSoundPlayer.h"
#import "AccelSoundPlayer.h"

@implementation TMSound

@synthesize m_sPath, m_bAlreadyPlaying, m_fStartPosition, m_fDuration;

- (id)initWithPath:(NSString *)inPath
{
    self = [super init];
    if (!self)
        return nil;

    m_sPath = inPath;
    m_fStartPosition = 0.0f;
    m_fDuration = 0.0f;
    m_bAlreadyPlaying = NO;

    return self;
}

- (id)initWithPath:(NSString *)inPath atPosition:(float)inTime
{
    self = [self initWithPath:inPath];
    if (!self)
        return nil;

    m_fStartPosition = inTime;

    return self;
}

- (id)initWithPath:(NSString *)inPath atPosition:(float)inTime withDuration:(float)inDuration
{
    self = [self initWithPath:inPath atPosition:inTime];
    if (!self)
        return nil;

    m_fDuration = inDuration;

    return self;
}

/* TMSoundSupport delegate work */
- (void)playBackStartedNotification
{
    m_bAlreadyPlaying = YES;
}

- (void)playBackFinishedNotification
{
    m_bAlreadyPlaying = NO;
}

@end
