//
//  CreditsRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "CreditsRenderer.h"
#import "TexturesHolder.h"
#import "Texture2D.h"

#import "TapManiaAppDelegate.h"
#import "MainMenuRenderer.h"
#import "MenuItem.h"

@implementation CreditsRenderer

- (id) initWithView:(EAGLView*)lGlView {
	self = [super initWithView:lGlView andCapacity:1];
	if(!self)
		return nil;
	
	int i;
	
	NSString* filePath = [[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"txt"];	
	NSArray* textsArray = [[NSArray arrayWithContentsOfFile:filePath] retain];
	
	// Alloc the textures array
	texturesArray = [[NSMutableArray alloc] initWithCapacity:[textsArray count]];
	
	// Cache the textures
	for(i=0; i<[textsArray count]; i++){
		[texturesArray addObject:[[Texture2D alloc] initWithString:[textsArray objectAtIndex:i] dimensions:CGSizeMake(320,20) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:16]];
	}
	
	[textsArray release];
	
	// Set starting pos
	currentPos = ([texturesArray count]*15);
	currentPos = -currentPos;
	
	[self enableBackButton]; // Handled by 'backPress:'
	[self publishMenu];
	
	return self;
}

- (void) dealloc {
	int i;

	for(i=0; i<[texturesArray count]; i++){
		[[texturesArray objectAtIndex:i] release];
	}	
	
	[super dealloc];
}


// Renders one scene of the credits screen :P
- (void)renderScene {
	CGRect				bounds = [glView bounds];
	int i, j;
	
	//Draw background
	glDisable(GL_BLEND);
	[[[TexturesHolder sharedInstance] getTexture:kTexture_Background] drawInRect:bounds];
	glEnable(GL_BLEND);
	
	// Draw the texts
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	for(i=0, j=[texturesArray count]-1; i<[texturesArray count]; i++,j--){
		[[texturesArray objectAtIndex:j] drawInRect:CGRectMake(0, currentPos+(i*15), 320, 15)];
	}
	
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	
	if(currentPos > 460) {
		currentPos = ([texturesArray count]*15);
		currentPos = -currentPos;
	}
	
	currentPos += 1.0f;
	
	//Swap the framebuffer
	[glView swapBuffers];
}	


#pragma mark Touch handlers
- (void) backPress:(id) sender {
	NSLog(@"Enter main menu (back from credits)...");
	[(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] activateRenderer:[[MainMenuRenderer alloc] initWithView:glView] looping:NO];
}

@end
