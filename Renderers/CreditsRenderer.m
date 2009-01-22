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
	self = [super init];
	if(!self)
		return nil;

	int i;
	
	// We will show the credits until this set to YES
	shouldReturn = NO;
	
	NSString* filePath = [[NSBundle mainBundle] pathForResource:@"Data/Credits" ofType:@"txt"];	
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
	
	return self;
}

- (void) dealloc {
	int i;

	for(i=0; i<[texturesArray count]; i++){
		[[texturesArray objectAtIndex:i] release];
	}	
	
	[super dealloc];
}

/* TMTransitionSupport methods */
- (void) setupForTransition {
	// Subscribe for input events
	[[InputEngine sharedInstance] subscribe:self];
}

- (void) deinitOnTransition {
	// Unsubscribe from input events
	[[InputEngine sharedInstance] unsubscribe:self];
}

/* TMRenderable methods */
- (void) render:(NSNumber*) fDelta {
	CGRect	bounds = [TapMania sharedInstance].glView.bounds;
	int i, j;
	
	//Draw background
	glDisable(GL_BLEND);
	[[[TexturesHolder sharedInstance] getTexture:kTexture_CreditsBackground] drawInRect:bounds];
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
	
	/* Check whether we should leave the credits screen already */
	if(shouldReturn){
		// Back to main menu
		[[TapMania sharedInstance] switchToScreen:[[MainMenuRenderer alloc] init]];
		shouldReturn = NO; // To be sure we not do the transition more than once
	}
}

/* TMGameUIResponder methods */
- (void) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	shouldReturn = YES;
}

@end
