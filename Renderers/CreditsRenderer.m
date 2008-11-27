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

#define kCreditsVelocity	20.0f;

@implementation CreditsRenderer

- (id) init {
	self = [super initWithCapacity:1];
	if(!self)
		return nil;
		
//	[self enableBackButton]; // Handled by 'backPress:'
//	[self publishMenu];
	
	return self;
}

- (void) dealloc {
	int i;

	for(i=0; i<[texturesArray count]; i++){
		[[texturesArray objectAtIndex:i] release];
	}	
	
	[super dealloc];
}

/* TMRenderable methods */
- (void) initForRendering:(NSObject*)data {
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
}

- (void) render:(NSNumber*) fDelta {
	CGRect	bounds = [RenderEngine sharedInstance].glView.bounds;
	int i, j;
	
	[self update:fDelta];
	
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
}

/* TMLogicUpdater method */
- (void) update:(NSNumber*)fDelta {
	if(currentPos > 460) {
		currentPos = ([texturesArray count]*15);
		currentPos = -currentPos;
	}
	
	currentPos += [fDelta floatValue]*kCreditsVelocity;
}


#pragma mark Touch handlers
- (void) backPress:(id) sender {
	NSLog(@"Enter main menu (back from credits)...");
//	[(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] registerRenderer:[[MainMenuRenderer alloc] initWithView:glView] withPriority:NO];
}

@end
