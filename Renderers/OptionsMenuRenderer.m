//
//  OptionsMenuRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TapManiaAppDelegate.h"
#import "TexturesHolder.h"

#import "OptionsMenuRenderer.h"
#import "MainMenuRenderer.h"

@implementation OptionsMenuRenderer

- (id) init {
	self = [super init];
	if(!self)
		return nil;

	// TODO: define some menu items

	return self;
}

- (void)render:(NSNumber*) fDelta {
	CGRect	bounds = [TapMania sharedInstance].glView.bounds;
	
	//Draw background
	/*
	glDisable(GL_BLEND);
	[[[TexturesHolder sharedInstance] getTexture:kTexture_] drawInRect:bounds];
	glEnable(GL_BLEND);
	 */
}	

# pragma mark Touch handling
- (void) backPress:(id)sender {
	NSLog(@"Enter main menu (back from options)...");
}

@end
