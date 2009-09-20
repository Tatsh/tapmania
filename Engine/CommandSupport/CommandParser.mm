//
//  CommandParser.mm
//  TapMania
//
//  Created by Alex Kremer on 9/20/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "CommandParser.h"
#import "TMCommand.h"

// This is a singleton class, see below
static CommandParser *sharedCommandParserDelegate = nil;

@interface CommandParser (Private)
- (Class) getCommandClassByName:(NSString*)inName;
@end


@implementation CommandParser

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	m_pDictionary = new TMCommandDictionary();
	
	return self;
}

- (void) dealloc {
	delete m_pDictionary;
	
	[super dealloc];
}

- (void) registerCommand:(Class)inCls withName:(NSString*)inName {
	m_pDictionary->insert(pair<string, Class>([inName UTF8String], inCls));
	TMLog(@"Registered %@ command for name '%@'.", inCls, inName);
}

- (Class) getCommandClassByName:(NSString*)inName {
	string name = [inName UTF8String];
	
	if(m_pDictionary->count(name) != 0) {
		return m_pDictionary->find(name)->second;
	}
	
	return (Class)0;
}

- (NSArray*) createCommandListFromString:(NSString*)inCmdList forRequestingObject:(NSObject*)inObj {
	// Split by ';' to get separate commands
	// Split each by ',' to get cmd name and arguments
	
	NSMutableArray* resultingCommandList = [[NSMutableArray alloc] initWithCapacity:1];
	NSArray* commands = [inCmdList componentsSeparatedByString:@";"];
	
	for(NSString* cmd in commands) {
		NSArray* cmdAndArgs = [cmd componentsSeparatedByString:@","];
		NSArray* args = nil;
		NSString* cmdName = nil;
		
		TMCommand* command = nil;
		
		if([cmdAndArgs count] > 1) {
			cmdName = [cmdAndArgs objectAtIndex:0];
			
			NSRange range;
			range.length = [cmdAndArgs count]-1;
			range.location = 1;
			args = [cmdAndArgs subarrayWithRange:range];
		} else {
			cmdName = cmd;
		}
		
		TMLog(@"Got CMD: '%@'", cmdName);
		Class commandClass = [self getCommandClassByName:[cmdName lowercaseString]];
		
		if(!commandClass) {
			TMLog(@"Command with name '%@' is not found. ignore.", cmdName);
			continue;
		}
		
		command = [[commandClass alloc] initWithArguments:args];
		[command invokeAtConstructionOnObject:inObj];
		
		[resultingCommandList addObject:command];
		
		if(args) {
			TMLog(@"Arguments: ");
			for(NSString* arg in args) {
				TMLog(@"'%@'", arg);
			}
		}
	}
	
	return resultingCommandList;
}

- (BOOL) runCommandList:(NSArray*)inCmdList forRequestingObject:(NSObject*)inObj {
	BOOL result = YES;
	
	for(TMCommand* cmd in inCmdList) {
		BOOL tmpRes = [cmd invokeOnObject:inObj];
		if(tmpRes == NO) result = NO;
	}
	
	return result;
}

#pragma mark Singleton stuff
+ (CommandParser*)sharedInstance {
    @synchronized(self) {
        if (sharedCommandParserDelegate == nil) {
            [[self alloc] init];
        }
    }
    return sharedCommandParserDelegate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedCommandParserDelegate	== nil) {
            sharedCommandParserDelegate = [super allocWithZone:zone];
            return sharedCommandParserDelegate;
        }
    }
	
    return nil;
}


- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
	// NOTHING
}

- (id)autorelease {
    return self;
}

@end
