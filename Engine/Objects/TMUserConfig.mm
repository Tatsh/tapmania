//
//  TMUserConfig.m
//  TapMania
//
//  Created by Alex Kremer on 13.05.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMUserConfig.h"
#import "TMSong.h"

@implementation TMUserConfig

- (id) init {
	self = [super init];
	if(!self)
		return nil;
		
	m_pConfigDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"default", @"theme", @"default", @"noteskin", 
						[NSNumber numberWithFloat:0.8f], @"sound", [NSNumber numberWithBool:NO], @"autotrack", 
						[NSNumber numberWithBool:NO], @"vispad", @"NONEXISTING", @"newsversion",
						[NSNumber numberWithInt:(int)kSongDifficulty_Beginner], @"prefdiff",
						[NSNumber numberWithBool:NO], @"landscape", nil];
	
	return self;
}

- (id) initWithContentsOfFile:(NSString*)configPath {
	self = [super init];
	if(!self)
		return nil;
	
	m_pConfigDict = [[NSMutableDictionary alloc] initWithContentsOfFile:configPath];
	
	return self;	
}

- (int) check {
	int errCount = 0;
	
	if(! [m_pConfigDict valueForKey:@"theme"]) {
		[m_pConfigDict setObject:@"default" forKey:@"theme"];
		++errCount;
	}
	
	if(! [m_pConfigDict valueForKey:@"noteskin"]) {
		[m_pConfigDict setObject:@"default" forKey:@"noteskin"];
		++errCount;
	}
	
	if(! [m_pConfigDict valueForKey:@"sound"]) {
		[m_pConfigDict setObject:[NSNumber numberWithFloat:0.8f] forKey:@"sound"];
		++errCount;
	}
	
	if(! [m_pConfigDict valueForKey:@"autotrack"]) {
		[m_pConfigDict setObject:[NSNumber numberWithBool:NO] forKey:@"autotrack"];
		++errCount;
	}

	if(! [m_pConfigDict valueForKey:@"vispad"]) {
		[m_pConfigDict setObject:[NSNumber numberWithBool:NO] forKey:@"vispad"];
		++errCount;
	}
	
	if(! [m_pConfigDict valueForKey:@"newsversion"]) {
		[m_pConfigDict setObject:@"NONEXISTING" forKey:@"newsversion"];
		++errCount;
	}
		
	if(! [m_pConfigDict valueForKey:@"prefdiff"]) {
		[m_pConfigDict setObject:[NSNumber numberWithInt:(int)kSongDifficulty_Beginner] forKey:@"prefdiff"];
		++errCount;
	}

	if(! [m_pConfigDict valueForKey:@"landscape"]) {
		[m_pConfigDict setObject:[NSNumber numberWithBool:NO] forKey:@"landscape"];
		++errCount;
	}
	
	return errCount;
}

- (void) forwardInvocation:(NSInvocation *)invocation {
    SEL aSelector = [invocation selector];
	
    if ([m_pConfigDict respondsToSelector:aSelector]) {		
        [invocation invokeWithTarget:m_pConfigDict];
	} else {
        [self doesNotRecognizeSelector:aSelector];
	}
}

- (BOOL) respondsToSelector:(SEL) aSelector {
	if([super respondsToSelector:aSelector]) {
		return YES;
	}
	
	if([m_pConfigDict respondsToSelector:aSelector]) {
		return YES;
	}
	
	return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	NSMethodSignature* sig = [super methodSignatureForSelector:aSelector];
	
	if(!sig) {
		sig = [m_pConfigDict methodSignatureForSelector:aSelector];
	}
	
	return sig;
}

- (void)setObject:(id)obj forKey:(id)key {
	[m_pConfigDict setObject:obj forKey:key];
}

- (NSObject*)valueForKey:(NSString*)key {
	return [m_pConfigDict valueForKey:key];
}

@end