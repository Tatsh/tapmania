//
//  CreditsRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "CreditsRenderer.h"
#import "TexturesHolder.h"

#import "TapManiaAppDelegate.h"
#import "MainMenuRenderer.h"
#import "MenuItem.h"

@implementation CreditsRenderer

- (id) initWithView:(EAGLView*)lGlView {
	self = [super initWithView:lGlView andCapacity:1];
	if(!self)
		return nil;
	
	currentPos = (float) -kCreditLines*15;
	
	NSString* textsArray[] = {
		@"~~~ TapMania ~~~", @"",
		@"Created by Alex (godexsoft) Kremer", @"", @"", @"",
		@"Visit http://code.google.com/p/tapmania", @"", @"",@"",
		@"This game is based on StepMania", @"Visit http://stepmania.com", @"", @"",
		@"Human knowledge belongs to the world!"
	};
	
	// Cache the textures
	for(int i=0; i<kCreditLines; i++){
		texturesArray[i] = [[Texture2D alloc] initWithString:textsArray[i] dimensions:CGSizeMake(320,20) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:16];
	}
	
	// Add menu button
	MenuItem* newItem = [[MenuItem alloc] initWithTitle:@"Back"];
	[newItem addTarget:self action:@selector(backPress:) forControlEvents:UIControlEventTouchUpInside];
	[newItem setFrame:CGRectMake(5, 435, 80, 20)];
	[_menuElements addObject:newItem];
	[glView addSubview:newItem];	
	
	return self;
}

- (void) dealloc {
	for(int i=0; i<kCreditLines; i++){
		[texturesArray[i] release];
	}	
	
	[super dealloc];
}


// Renders one scene of the credits screen :P
- (void)renderScene {
	CGRect				bounds = [glView bounds];
	
	//Draw background
	glDisable(GL_BLEND);
	[[[TexturesHolder sharedInstance] getTexture:kTexture_Background] drawInRect:bounds];
	glEnable(GL_BLEND);
	
	// Draw the texts
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	for(int i=0, j=kCreditLines-1; i<kCreditLines; i++,j--){
		[texturesArray[j] drawInRect:CGRectMake(0, currentPos+(i*15), 320, 15)];
	}
	
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	
	if(currentPos > 460) 
		currentPos = (float) -kCreditLines*15;
	
	currentPos += 1.3f;
	
	//Swap the framebuffer
	[glView swapBuffers];
}	


#pragma mark Touch handlers
- (void) backPress:(id) sender {
	NSLog(@"Enter main menu (back from credits)...");
	[(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] activateRenderer:[[MainMenuRenderer alloc] initWithView:glView] noSceneRendering:YES];
}

@end
