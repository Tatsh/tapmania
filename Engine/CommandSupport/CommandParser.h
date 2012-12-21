//
//  $Id$
//  CommandParser.h
//  TapMania
//
//  Created by Alex Kremer on 9/20/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#ifdef __cplusplus

#define REG_COMMAND(name,cls)    [[CommandParser sharedInstance] registerCommand:cls withName:name];

#include <map>
#include <string>

using namespace std;

typedef map<string, Class> TMCommandDictionary;

#endif

@class TMCommand;

@interface CommandParser : NSObject
{
    TMCommandDictionary *m_pDictionary;
}

- (void)registerCommand:(Class)inCls withName:(NSString *)inName;

- (TMCommand *)createCommandListFromString:(NSString *)inCmdList forRequestingObject:(NSObject *)inObj;

- (BOOL)runCommandList:(TMCommand *)inCmdList forRequestingObject:(NSObject *)inObj;

+ (CommandParser *)sharedInstance;

@end
