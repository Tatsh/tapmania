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

- (id) initWithSong:(TMSong*) lSong {
	NSString* title = [NSString stringWithFormat:@"%@ - %@", lSong.artist, lSong.title];
	self = [super initWithTitle:title];
	if(!self)
		return nil;
	
	song = lSong;	
	
	return self;
}

- (void) dealloc {
	[song release];
	[super dealloc];
}

@end
