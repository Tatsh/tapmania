//
//  ScreenCommand.mm
//  TapMania
//
//  Created by Alex Kremer on 21.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "ScreenCommand.h"
#import "ThemeManager.h"
#import "TapMania.h"

@implementation ScreenCommand

- (id) initWithArguments:(NSArray*) inArgs andInvocationObject:(NSObject*) inObj {
	self = [super initWithArguments:inArgs andInvocationObject:inObj];
	if(!self)
		return nil;
	
	if([inArgs count] != 1) {
		TMLog(@"Wrong argument count for command 'screen'. abort.");
		return nil;
	}
	
	return self;
}

- (BOOL) invokeOnObject:(NSObject*)inObj {
	
	// Get the screen name to switch
	NSString* screenName = [self getValueFromString:[m_aArguments objectAtIndex:0] withObject:inObj];
	
	// Every screen has a root metric dictionary in the root of the theme metrics
	// So just get that metric dictionary. The screen class is called $SCREENNAME+Renderer
	NSString* screenClass = [screenName stringByAppendingString:@"Renderer"];
	Class cls = [[NSBundle mainBundle] classNamed:screenClass];
	
	NSDictionary* screenMetrics = DICT_METRIC(screenName);
	
	if(!cls || !screenMetrics) {
		TMLog(@"Invalid screen. Class '%@' or metrics for '%@' not found!", screenClass, screenName);
		return NO;
	}
	
	[[TapMania sharedInstance] switchToScreen:[[cls alloc] initWithMetrics:screenName]];
	
	return YES;
}

@end
