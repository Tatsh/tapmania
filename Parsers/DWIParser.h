//
//  $Id$
//  DWIParser.h
//  TapMania
//  Some of the code here is taken from NotesLoaderDWI.cpp file from StepMania.
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMSteps.h"

@class TMSong;

enum
{
    DANCE_NOTE_NONE = 0,
    DANCE_NOTE_PAD1_LEFT,
    DANCE_NOTE_PAD1_UPLEFT,
    DANCE_NOTE_PAD1_DOWN,
    DANCE_NOTE_PAD1_UP,
    DANCE_NOTE_PAD1_UPRIGHT,
    DANCE_NOTE_PAD1_RIGHT
};

@interface DWIParser : NSObject
{

}

+ (TMSong *)parseFromFile:(NSString *)filename;

+ (TMSteps *)parseStepsFromFile:(NSString *)filename forDifficulty:(TMSongDifficulty)difficulty forSong:(TMSong *)song;

@end
