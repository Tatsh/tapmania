//
//  TMScreen.m
//  TapMania
//
//  Created by Alex Kremer on 10.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMScreen.h"
#import "InputEngine.h"
#import "TapMania.h"
#import "EAGLView.h"
#import "ThemeManager.h"

#import "TMControl.h"
#import "MenuItem.h"
#import "Label.h"
#import "TogglerItem.h"
#import "Slider.h"

@implementation TMScreen

- (id) initWithMetrics:(NSString*)inMetricsKey {
	// A screen is always fullscreen :P
	self = [super initWithShape:[TapMania sharedInstance].m_pGlView.bounds];
	if(!self)
		return nil;
		
	NSDictionary* conf = DICT_METRIC(inMetricsKey);
	
	// Go through all the elements defined for the screen and look for buttons, labels, togglers etc.
	for(NSObject* element in conf) {
		TMLog(@"Got elem: %@", element);
		
		if([element isCaseInsensitiveLike:@"*button"]) {
			TMControl* ctrl = [[MenuItem alloc] initWithMetrics:[NSString stringWithFormat:@"%@ %@", inMetricsKey, element]];
			[self pushBackControl:ctrl];
		}
		else if([element isCaseInsensitiveLike:@"*label"]) {
			TMControl* ctrl = [[Label alloc] initWithMetrics:[NSString stringWithFormat:@"%@ %@", inMetricsKey, element]];
			[self pushBackControl:ctrl];
		}
		else if([element isCaseInsensitiveLike:@"*slider"]) {
			TMControl* ctrl = [[Slider alloc] initWithMetrics:[NSString stringWithFormat:@"%@ %@", inMetricsKey, element]];
			[self pushBackControl:ctrl];
		}
		else if([element isCaseInsensitiveLike:@"*toggler"]) {
			TMControl* ctrl = [[TogglerItem alloc] initWithMetrics:[NSString stringWithFormat:@"%@ %@", inMetricsKey, element]];
			[self pushBackControl:ctrl];
		}
	}
	
	return self;
}


/* TMTransitionSupport methods */
- (void) setupForTransition {
	[[InputEngine sharedInstance] subscribe:self];
}

- (void) deinitOnTransition {
	[[InputEngine sharedInstance] unsubscribe:self];
}

@end

