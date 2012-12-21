//
//  $Id$
//  TMSound.h
//  TapMania
//
//  Created by Alex Kremer on 19.08.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMSoundSupport.h"

@interface TMSound : NSObject <TMSoundSupport>
{
    NSString *m_sPath;
    BOOL m_bAlreadyPlaying;
    float m_fStartPosition;
    float m_fDuration;    // 0 duration indicates full track playback
}

@property(assign, nonatomic, readonly, getter=playing) BOOL m_bAlreadyPlaying;
@property(retain, nonatomic, readonly, getter=path) NSString *m_sPath;
@property(assign, nonatomic, readonly, getter=position) float m_fStartPosition;
@property(assign, nonatomic, readonly, getter=duration) float m_fDuration;

- (id)initWithPath:(NSString *)inPath;

- (id)initWithPath:(NSString *)inPath atPosition:(float)inTime;

- (id)initWithPath:(NSString *)inPath atPosition:(float)inTime withDuration:(float)inDuration;

@end
