//
//  CreditsRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "CreditsRenderer.h"
#import "Texture2D.h"
#import "InputEngine.h"
#import "ThemeManager.h"

#import "EAGLView.h"
#import "TapMania.h"
#import "MainMenuRenderer.h"
#import "MenuItem.h"

#define kCreditsVelocity	20.0f;

@implementation CreditsRenderer

Texture2D* t_CreditsBG;

- (id) init {
	self = [super init];
	if(!self)
		return nil;

	int i;
	
	// Cache graphics
	t_CreditsBG = [[ThemeManager sharedInstance] texture:@"Credits Background"];
	
	// We will show the credits until this set to YES
	m_bShouldReturn = NO;
	
	NSString* filePath = [[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"plist"];	
	NSArray* textsArray = [[NSArray arrayWithContentsOfFile:filePath] retain];
	
	// Alloc the textures array
	m_aTexturesArray = [[NSMutableArray alloc] initWithCapacity:[textsArray count]];
		
	// Cache the textures
	for(i=0; i<[textsArray count]; i++){
		[m_aTexturesArray addObject:[[Texture2D alloc] initWithString:[textsArray objectAtIndex:i] dimensions:CGSizeMake(320,20) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:16]];
	}
	
	[textsArray release];
	
	// Set starting pos
	m_fCurrentPos = ([m_aTexturesArray count]*15);
	m_fCurrentPos = -m_fCurrentPos;		
	
	return self;
}

- (void) dealloc {
	int i;

	for(i=0; i<[m_aTexturesArray count]; i++){
		[[m_aTexturesArray objectAtIndex:i] release];
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
	[t_CreditsBG drawInRect:bounds];
	glEnable(GL_BLEND);
	
	// Draw the texts
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	for(i=0, j=[m_aTexturesArray count]-1; i<[m_aTexturesArray count]; i++,j--){
		[[m_aTexturesArray objectAtIndex:j] drawInRect:CGRectMake(0, m_fCurrentPos+(i*15), 320, 15)];
	}
	
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
}

/* TMLogicUpdater method */
- (void) update:(NSNumber*)fDelta {
	if(m_fCurrentPos > 460) {
		m_fCurrentPos = ([m_aTexturesArray count]*15);
		m_fCurrentPos = -m_fCurrentPos;
	}
	
	m_fCurrentPos += [fDelta floatValue]*kCreditsVelocity;
	
	/* Check whether we should leave the credits screen already */
	if(m_bShouldReturn){
		// Back to main menu
		[[TapMania sharedInstance] switchToScreen:[[MainMenuRenderer alloc] init]];
		m_bShouldReturn = NO; // To be sure we not do the transition more than once
	}
}

/* TMGameUIResponder methods */
- (void) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	m_bShouldReturn = YES;
}

@end
