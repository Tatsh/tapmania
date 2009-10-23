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

- (BOOL) invokeOnObject:(NSObject*)inObj {
	
	// Get the screen name to switch
	NSString* screenName = [m_aArguments objectAtIndex:0];
	
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
