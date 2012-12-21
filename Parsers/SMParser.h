//
//  $Id$
//  SMParser.h
//  TapMania
//
//  Created by Alex Kremer on 18.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

@class TMSong;

#import "TMSteps.h"

/* This class is used to parse .sm file format */
@interface SMParser : NSObject
{
}

+ (TMSong *)parseFromFile:(NSString *)filename;

+ (TMSteps *)parseStepsFromFile:(NSString *)filename forDifficulty:(TMSongDifficulty)difficulty forSong:(TMSong *)song;

@end
