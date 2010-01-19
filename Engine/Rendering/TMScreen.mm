//
//  $Id$
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
#import "Texture2D.h"

#import "TMControl.h"
#import "MenuItem.h"
#import "Label.h"
#import "TogglerItem.h"
#import "Slider.h"
#import "ImageButton.h"

@implementation TMScreen

- (id) initWithMetrics:(NSString*)inMetricsKey {
	// A screen is always fullscreen :P
	self = [super initWithShape:[TapMania sharedInstance].m_pGlView.bounds];
	if(!self)
		return nil;
		
	NSDictionary* conf = DICT_METRIC(inMetricsKey);
	
	// Load Background texture
	t_BG = TEXTURE( ([NSString stringWithFormat:@"%@ Background", inMetricsKey]) );
	if(!t_BG) {
		// Load default
		t_BG = TEXTURE(@"Common SharedBackground");
	}
	
	// Go through all the elements defined for the screen and look for buttons, labels, togglers etc.
	for(NSString* element in conf) {
		TMLog(@"Got elem: %@", element);
		//
//		NSArray* arr = [element componentsSeparatedByString:@"_"];
//		if([arr count] > 1) {
//			for(int i=1; i<[arr count]; ++i) {
//				if(i!=1) {
//					element = [element stringByAppendingString:@"_"];					
//				}
//				
//				element = [element stringByAppendingString:[arr objectAtIndex:i]];
//			}
//		}
		
		if([element hasSuffix:@"Button"]) {
			TMControl* ctrl = [[MenuItem alloc] initWithMetrics:[NSString stringWithFormat:@"%@ %@", inMetricsKey, element]];
			[self pushBackControl:ctrl];
		}
		else if([element hasSuffix:@"Label"]) {
			TMControl* ctrl = [[Label alloc] initWithMetrics:[NSString stringWithFormat:@"%@ %@", inMetricsKey, element]];
			[self pushBackControl:ctrl];
		}
		else if([element hasSuffix:@"Slider"]) {
			TMControl* ctrl = [[Slider alloc] initWithMetrics:[NSString stringWithFormat:@"%@ %@", inMetricsKey, element]];
			[self pushBackControl:ctrl];
		}
		else if([element hasSuffix:@"Toggler"]) {
			TMControl* ctrl = [[TogglerItem alloc] initWithMetrics:[NSString stringWithFormat:@"%@ %@", inMetricsKey, element]];
			[self pushBackControl:ctrl];
		}		
		else if([element hasSuffix:@"Img"]) {
			TMControl* ctrl = [[ImageButton alloc] initWithMetrics:[NSString stringWithFormat:@"%@ %@", inMetricsKey, element]];
			[self pushBackControl:ctrl];
		}
	}
	
	return self;
}

/* TMRenderable method */
- (void) render:(float)fDelta {
	// Render BG
	CGRect	bounds = [TapMania sharedInstance].glView.bounds;
	[t_BG drawInRect:bounds];	
	
	// Render children
	[super render:fDelta];
}

/* TMTransitionSupport methods */
- (void) setupForTransition {
	[[InputEngine sharedInstance] subscribe:self];
}

- (void) deinitOnTransition {
	[[InputEngine sharedInstance] unsubscribe:self];
}

@end

