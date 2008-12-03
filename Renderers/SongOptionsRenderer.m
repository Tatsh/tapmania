//
//  SongOptionsRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 12.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "SongOptionsRenderer.h"
#import "TexturesHolder.h"
#import "SongPlayRenderer.h"
#import "SongPickerMenuRenderer.h"
#import "TapManiaAppDelegate.h"

#import <syslog.h>

@implementation SongOptionsRenderer

// Real constructor
- (id) initWithSong:(TMSong*)lSong {
	self = [self init];
	
	song = lSong;	
	TMSongDifficulty dif = kSongDifficulty_Invalid;
	options = [[TMSongOptions alloc] init];
	
	NSMutableArray* arr = nil;
	
	/* Add toggler for difficulty */
	arr = [[NSMutableArray alloc] initWithCapacity:5];

	for(; dif < kNumSongDifficulties; dif++) {
		if([song isDifficultyAvailable:dif]) {
			NSString* difStr = [[NSString stringWithFormat:@"%@ (%d)", 
					[TMSong difficultyToString:dif], [song getDifficultyLevel:dif]] retain];
			[arr addObject:[[TogglerItemObject alloc] initWithTitle:difStr andValue:[NSNumber numberWithInt:dif]]];
		}
	}	
	
	difficultyToggler = [[TogglerItem alloc] initWithElements:arr];
	[self addMenuItem:difficultyToggler andHandler:nil onTarget:nil];

	[arr release];

	/* Add toggler for speed modifiers */
	arr = [[NSMutableArray alloc] initWithCapacity:5];
	TMSpeedModifiers sMod = kSpeedMod_1x;

	for(; sMod < kNumSpeedMods; sMod++) {
		NSString* sModStr = [TMSongOptions speedModAsString:sMod];
		[arr addObject:[[TogglerItemObject alloc] initWithTitle:sModStr andValue:[NSNumber numberWithInt:sMod]]];
	}

	speedModsToggler = [[TogglerItem alloc] initWithElements:arr];
	[self addMenuItem:speedModsToggler andHandler:nil onTarget:nil];
	
	[arr release];
	
	return self;
}

- (void)dealloc {
	[song release];
	[options release];

	// The togglers will be automatically realesed by the superclass
	
	[super dealloc];
}

- (void)render:(NSNumber*) fDelta {
	CGRect	bounds = [RenderEngine sharedInstance].glView.bounds;
	
	//Draw background
	glDisable(GL_BLEND);
	[[[TexturesHolder sharedInstance] getTexture:kTexture_Background] drawInRect:bounds];
	glEnable(GL_BLEND);
}	

# pragma mark Touch handling
- (void) goPress:(id)sender {
	NSLog(@"Start song... %@", song.filePath);	

	// Assign speed modifier
	[options setSpeedMod:[(NSNumber*)[[speedModsToggler getCurrent] value] intValue]]; 

	// Assign difficulty
	[options setDifficulty:[(NSNumber*)[[difficultyToggler getCurrent] value] intValue]];

	syslog(LOG_DEBUG, "Going to play with speedMod: %d and difficulty %d", options.speedMod, options.difficulty);

	/*
	SongPlayRenderer* songPlayRenderer = [[SongPlayRenderer alloc] initWithView:glView];
	[songPlayRenderer playSong:song withOptions:options];
	 */
}

- (void) backPress:(id)sender {
	NSLog(@"Go to song picker from song options menu...");
	// [(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] 
	//	registerRenderer:[[SongPickerMenuRenderer alloc] initWithView:glView] withPriority:NO];
}

@end
