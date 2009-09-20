//
//  TMCommand.h
//  TapMania
//
//  Created by Alex Kremer on 9/20/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

@interface TMCommand : NSObject {
	NSArray*	m_aArguments;
}

- (id) initWithArguments:(NSArray*) inArgs;

// This is invoked when the command is being parsed (constructed)
- (BOOL) invokeAtConstructionOnObject:(NSObject*)inObj;

// This is invoked when it's time to fire the command
- (BOOL) invokeOnObject:(NSObject*)inObj;

@end
