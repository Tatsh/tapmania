//
//  LogicEngine.h
//  TapMania
//
//  Created by Alex Kremer on 01.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMRunLoop.h"

@interface LogicEngine : NSObject <TMRunLoopDelegate> {
	TMRunLoop		*logicRunLoop;
	
	// The lock for logicRunLoop is taken from the renderEngine
}

- (void) registerLogicUpdater:(NSObject*) logicUpdater withPriority:(TMRunLoopPriority) priority;
- (void) clearLogicUpdaters;

+ (LogicEngine *)sharedInstance;

@end
