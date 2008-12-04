//
//  SongPickerMenuItem.m
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "SongPickerMenuItem.h"


@implementation SongPickerMenuItem

@synthesize song;

- (id) initWithSong:(TMSong*) lSong andShape:(CGRect)lShape {
	self = [super init];
	if(!self) 
		return nil;
	
	shape = lShape;
	song = lSong;	
	
	return self;
}

- (void) dealloc {
	[song release];
	[super dealloc];
}


/* TMRenderable stuff */
- (void) render:(NSNumber*)fDelta {
	CGRect capRect = CGRectMake(shape.origin.x, shape.origin.y, 12.0f, 40.0f);
	CGRect bodyRect = CGRectMake(shape.origin.x+12.0f, shape.origin.y, shape.size.width-12.0f, 40.0f); 
//	[[[TexturesHolder sharedInstance] getTexture:kTexture_SongSelectionWheelItem] drawFrame: inRect:capRect];
}

@end
