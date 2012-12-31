//
//  $Id$
//  CDTitleDisplay.h
//  TapMania
//
//  Created by Alex Kremer on 31.12.12.
//  Copyright 2012 Godexsoft. All rights reserved.
//
//  Happy new year :D
//

#import "TMLogicUpdater.h"
#import "TMRenderable.h"
#import "TMMessageSupport.h"

@class TMSong;

@interface CDTitleDisplay : NSObject <TMLogicUpdater, TMRenderable, TMMessageSupport>
{
    /* Metrics and such */
    TMSong *m_pCurSong;
}

- (id)initWithMetrics:(NSString *)metricsKey;

- (void)updateWithSong:(TMSong*)song;

@end
