//
//  $Id$
//  BpmDisplay.h
//  TapMania
//
//  Created by Alex Kremer on 30.12.12.
//  Copyright 2012 Godexsoft. All rights reserved.
//

#import "TMLogicUpdater.h"
#import "TMRenderable.h"
#import "TMMessageSupport.h"

@class FontString;
@class TMSong;

@interface BpmDisplay : NSObject <TMLogicUpdater, TMRenderable, TMMessageSupport>
{
    FontString *m_pBpmStr;

    /* Metrics and such */
    // CGPoint mt_ComboMeter, mt_ComboStr;
    TMSong *m_pCurSong;
}

- (id)initWithMetrics:(NSString *)metricsKey;

- (void)updateWithSong:(TMSong*)song;

@end
