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

- (id) initWithView:(EAGLView*)lGlView {
	self = [super initWithView:lGlView andCapacity:kNumOptionsMenuItems];
	if(!self)
		return nil;
	
	// TODO: define some menu items
	
	// Back button	
	[self enableBackButton]; // Handled by 'backPress:'
	[self publishMenu];

	return self;
}

- (void)renderScene {
	CGRect				bounds = [glView bounds];
	
	//Draw background
	glDisable(GL_BLEND);
	[[[TexturesHolder sharedInstance] getTexture:kTexture_Background] drawInRect:bounds];
	glEnable(GL_BLEND);
	
	//Swap the framebuffer
	[glView swapBuffers];
}	

# pragma mark Touch handling
- (void) backPress:(id)sender {
	NSLog(@"Enter main menu (back from options)...");
	[(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] registerRenderer:[[MainMenuRenderer alloc] initWithView:glView] withPriority:NO];
}

@end
