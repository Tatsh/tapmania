//
//  $Id$
//  TMControl.h
//  TapMania
//
//  Created by Alex Kremer on 16.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMEffectSupport.h"
#import "TMView.h"

@class TMCommand;

/* A control is a view that can be pressed and that supports all kind of control effects */
@interface TMControl : TMView <TMEffectSupport>
{
    id m_idActionDelegate;            // delegate to invoke the selector on
    SEL m_oActionHandler;            // selector which should be invoked on control touch

    id m_idChangedDelegate;        // delegate to invoke the selector on
    SEL m_oChangedActionHandler;    // selector which should be invoked on finger drag over the control

    TMCommand *m_pOnCommand;                // used if non-nil; commands to perform when focused
    TMCommand *m_pOffCommand;                // used if non-nil; commands to perform when focus lost
    TMCommand *m_pHitCommand;                // used if non-nil; commands to perform when touch released in the control area
    TMCommand *m_pSlideCommand;            // used if non-nil; commands to perform when sliding

    NSString *m_sControlPath;                // Control full qualified name (e.g. "MainMenu PlayButton")
}

- (id)initWithMetrics:(NSString *)inMetricsKey;

- (void)initCommands:(NSString *)inMetricsKey;

- (void)setActionHandler:(SEL)selector receiver:(id)receiver;

- (void)setChangedActionHandler:(SEL)selector receiver:(id)receiver;

- (void)setOnCommand:(TMCommand *)inCmd;

- (void)setOffCommand:(TMCommand *)inCmd;

- (void)setHitCommand:(TMCommand *)inCmd;

- (void)setSlideCommand:(TMCommand *)inCmd;

- (void)initGraphicsAndSounds:(NSString *)inMetricsKey;

- (NSString *)getControlPath;

@end
