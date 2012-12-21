//
//  $Id$
//  TMCommand.h
//  TapMania
//
//  Created by Alex Kremer on 9/20/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMLogicUpdater.h"
#import "TMRenderable.h"

@interface TMCommand : NSObject <TMLogicUpdater, TMRenderable, NSCopying>
{
    NSArray *m_aArguments;

    TMCommand *m_pNextCmd;                // This is for chaining commands into lists
    NSObject *m_pInvocationObject;
}

- (id)initWithArguments:(NSArray *)inArgs andInvocationObject:(NSObject *)inObj;

// This is invoked when the command is being parsed (constructed)
- (BOOL)invokeAtConstructionOnObject:(NSObject *)inObj;

// This is invoked when it's time to fire the command
- (BOOL)invokeOnObject:(NSObject *)inObj;

// Value getters
- (NSObject *)getValueFromString:(NSString *)str withObject:(NSObject *)inObj;

- (void)setInvocationObject:(NSObject *)inObj;

- (NSObject *)getInvocationObject;

- (void)setNextCommand:(TMCommand *)inCmd;

@end
