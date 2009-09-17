//
//  NewsDialog.m
//  TapMania
//
//  Created by Alex Kremer on 8/11/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "NewsDialog.h"
#import "TapMania.h"
#import "EAGLView.h"
#import "NewsFetcher.h"
#import "Texture2D.h"

@implementation NewsDialog

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	// Fetch news text and generate texture text from it
	NSString* news = [[NewsFetcher sharedInstance] getUnreadNews];
	TMLog(@"Got news from NewsFetcher: %@", news);
	
	m_pNewsText = [[Texture2D alloc] initWithString:news dimensions:CGSizeMake(250, 380) 
							alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:18];
	TMLog(@"Created texture out of it!");
	
	return self;
}

- (void) dealloc {
	[m_pNewsText release];
	
	[super dealloc];
}

/* TMRenderable methods */
- (void) render:(float) fDelta {
	CGRect	bounds = [TapMania sharedInstance].glView.bounds;
	[super render:fDelta];
	
	if(m_pNewsText) {
		// Draw the text
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
		[m_pNewsText drawAtPoint:CGPointMake(160, 140)];
	
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
		glDisable(GL_BLEND);
	}
}

@end
